Weekend Project: Dispute Review Queue (Rails)
Goal: Build a small but realistic slice of a financial platform: a Dispute Review Queue with
minimal admin tooling, webhook ingestion handled by background workers, and a couple of
reporting pages. The purpose is to see how you plan 4–5 steps ahead, make tradeoffs, and
explain decisions—not to recreate an enterprise system.
Stack constraints
● Ruby (3.4.x recommended), Rails 8.x, PostgreSQL, Redis, Sidekiq (OSS)
● Local only (no cloud accounts). Homebrew install is fine. Docker optional.
● No paid services. No external signups.
● Include simple RBAC (admin/reviewer/read_only).
● Do not include sensitive credentials in source. Use environment variables or Rails
credentials.

What to build
You’ll implement a miniature dispute management flow for payment-like records we’ll call
charges (think: transactions that may later be disputed). There’s no external gateway—treat all
data as local. You’ll:
1. Ingest webhook events (simulated locally) for disputes on charges.
2. Maintain a dispute review queue with a simple state machine and audit trail.
3. Provide a tiny admin UI to triage and transition disputes, attach evidence, and leave
notes.
4. Produce two reporting pages that exercise money math and time-zone boundaries.
Scope guardrails: Aim for clarity over features. Choose simple, consistent patterns
and explain why.

Core domain
Entities (suggested)
● Charge: minimal representation of a transaction that could be disputed.
● Dispute: created by webhook events, linked to a Charge.
● Evidence: file references/metadata the reviewer attaches.

● CaseAction (audit log): who did what, when, and why.
Optional: an Adjustment record you may use to reflect a final financial impact
when a dispute is lost or won (positive/negative). This lets you show money math
without building a full ledger.
Dispute states (baseline)
● open → needs_evidence → awaiting_decision → won | lost
● Allow reopened from won/lost with justification.
You may refine names/transitions; document the rationale and invariants.

Webhook ingestion (local simulation)
Build an HTTP endpoint, e.g. POST /webhooks/disputes that accepts JSON bodies
representing dispute lifecycle events. On receipt:
● Validate basic schema (charge external ID, dispute external ID, amount, currency,
status, event type, occurred_at).
● Enqueue a Sidekiq job to process the event; the controller should be thin.
● Persist the raw external payload (JSONB) on the Dispute (or a related table) for
traceability.
Event semantics to support
● Create dispute (first time we see a dispute.opened).
● Update dispute status (dispute.updated), potentially out of order.
● Close dispute (dispute.closed) with outcome won or lost.
Provide a tiny CLI/script you can run locally to send sample events (e.g., curl, a
bash script, or a simple Ruby script). Keep it local—no accounts.

Idempotency &amp; jobs (required)
Requirement: Your webhook endpoint and Sidekiq workers must be idempotent. Duplicate
deliveries will occur; updates may arrive out of order.
● Choose an idempotency strategy and how you handle out-of-order updates. Explain the
tradeoffs and the chosen uniqueness keys.

Authentication &amp; RBAC
Gate the admin and reporting features behind sign‑in and a simple, explicit RBAC layer.
Roles (suggested)
● admin – full access; transition any dispute, attach/remove evidence; optional user
management.
● reviewer – triage and transition disputes; attach evidence; no user/system management.
● read_only – view queue, case details, and reports only.
Requirements
● Provide a simple way to create a local user in each role (rake task or script).

Evidence handling
On a case, allow attaching evidence (text note and an optional local file path or upload). Store
metadata in JSONB.

Reporting (two pages)
1. Daily Dispute Volume: table + chart‑friendly JSON showing counts and total disputed
amount per day for a chosen window. Supports ?from=YYYY-MM-DD&amp;to=YYYY-MM-
DD.
2. Time‑To‑Decision: distribution (p50/p90) of duration from dispute.opened to final
won/lost, grouped by week.
Time handling: Display all timestamps and resolve report filters using the current user&#39;s time
zone (store a time_zone on User, with a sensible default). It&#39;s fine to store timestamps in UTC
and convert at grouping/filter boundaries. Keep it simple and consistent.

Money math
Assume USD as the currency
Data model (suggested starting point)

You are free to alter this, but explain why.
● charges(id, external_id UNIQUE, amount_cents, currency, created_at)
● disputes(id, charge_id FK, external_id UNIQUE, status, opened_at, closed_at,
amount_cents, currency, external_payload JSONB, created_at, updated_at)
● case_actions(id, dispute_id, actor, action, note, details JSONB, created_at)
● evidence(id, dispute_id, kind, metadata JSONB, created_at)
● Optional: adjustments(id, dispute_id, amount_cents, currency, reason, created_at)
Deliverables &amp; submission
● GitHub repo with a clear README covering setup, operations, and the key decisions
above.
● A 5–7 minute walkthrough video explaining architecture, data flow, and where you
made judgment calls. Keep it practical. We care about judgment and clarity more than
features.
● (Optional but appreciated): If you record more of your process (screen capture of
building), include the link.
We will run your app locally on macOS with Homebrew Postgres/Redis. Please include:
● Bootstrapping commands (e.g., bin/setup, migrations, rails s, Sidekiq worker start).
● A simple local script to send sample webhooks (curl or Ruby).

Getting started (suggested)
● bin/setup to create DB, run migrations, and prepare Redis keys/queues.
● Start Rails server and Sidekiq.
● Use scripts/post_webhook.sh or a Ruby script to send example events.
● Populate a couple of Charges manually or via a tiny rake task (optional).