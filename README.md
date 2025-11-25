## Requirements

Please go through this [requirement.md](https://github.com/AjayBarot7035/disputor/blob/main/requirement.md) file for the detail requirements

## Prerequisites

Please follow the [SETUP.md](https://github.com/AjayBarot7035/disputor/blob/main/SETUP.md) file for all the setup instructions(Only for macos users).

## How to review the code, decisions and process

Please review the codebase commit by commit starting with first [commit](https://github.com/AjayBarot7035/disputor/commit/3fbf58e5cf10bb0fa3108b139233e08773d83659).


## TODO tasks(future enhancements)
1. Create setup instructions file for Linux and WSL users
2. UI/UX improvements(table, sections, div, flash)
3. Add the pagination with page size 10
4. Add the rdoc documentation for all the ruby code
5. Implement user management so we can easily onboard the user
6. Investigate and replace sidekiq with Solidus if possible
7. Investigate Turbo, Propshaft, Stimulus, Turbo frames as its available in 8.1.1
8. Introduce tailwindcss-rails and move code according to it.

## Instructions

## Step 1: Create Test Users

Create sample users with different roles:

```bash
bin/rails users:sample
```

This creates:
- `admin@disputor.local` / `admin123` (admin role)
- `reviewer@disputor.local` / `reviewer123` (reviewer role)
- `readonly@disputor.local` / `readonly123` (read_only role)

Or create a custom user:
```bash
bin/rails users:create[your@email.com,password123,admin,UTC]
```

## Step 2: Start the Application

**Terminal 1 - Rails server:**
```bash
bin/rails server
```

**Terminal 2 - Sidekiq worker:**
```bash
bundle exec sidekiq
```

## Step 3: Access the Application

1. **Open your browser:** http://localhost:3000
2. **Sign in** with one of the test users (e.g., `admin@disputor.local` / `admin123`)

## Step 4: Create Test Data

### Create a Charge (via Rails console)
```bash
bin/rails console
```

```ruby
charge = Charge.create!(
  external_id: "chg_test_#{Time.now.to_i}",
  amount_cents: 5000,
  currency: "USD"
)
```

### Send Webhook Events

**Option A: Using the script**
```bash
./scripts/post_webhook.sh dispute.opened dsp_test_1 chg_test_1

./scripts/post_webhook.sh dispute.updated dsp_test_1

./scripts/post_webhook.sh dispute.closed dsp_test_1
```

**Option B: Using curl directly**
```bash
curl -X POST http://localhost:3000/webhooks/disputes \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "dispute.opened",
    "event_id": "evt_123",
    "dispute": {
      "external_id": "dsp_123",
      "charge_external_id": "chg_test_1",
      "amount_cents": 5000,
      "currency": "USD",
      "status": "open",
      "occurred_at": "2024-11-25T10:00:00Z"
    }
  }'
```

**Option C: Using Rails console**
```ruby
charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
dispute = Dispute.create!(
  charge: charge,
  external_id: "dsp_123",
  amount_cents: 1000,
  currency: "USD",
  opened_at: Time.current,
  status: "open"
)
```

## Step 5: Test the UI Features

### Dispute Queue
- Navigate to: http://localhost:3000 (root)
- View all disputes in a table
- Click "View" to see dispute details

### Dispute Details
- View dispute information
- Transition Status: Select a valid status and add a note
- Reopen Dispute: For won/lost disputes, use the reopen form
- Add Evidence: Upload files and add notes
- View Audit Trail: See all case actions

### Reports
- Daily Volume: http://localhost:3000/reports/daily_volume
  - Filter by date range
  - Download JSON for charts
- Time To Decision: http://localhost:3000/reports/time_to_decision
  - View p50/p90 percentiles by week
  - Download JSON

### RBAC Testing
- Admin: Can transition disputes, add evidence, view reports
- Reviewer: Can transition disputes, add evidence, view reports(no user management its future enhancement)
- Read Only: Can view disputes and reports, but forms are disabled

## Step 6: Monitor Background Jobs

- Sidekiq Web UI: http://localhost:3000/sidekiq (development only)
- View webhook processing jobs
- Check job status and retries

## Troubleshooting

### Webhooks not processing?
- Make sure Sidekiq is running: `bundle exec sidekiq`
- Check Sidekiq Web UI: http://localhost:3000/sidekiq
- Check logs: `tail -f log/development.log`

### Can't sign in?
- Verify users exist: `bin/rails console` then `User.all`
- Create users: `bin/rails users:sample`

### No disputes showing?
- Create a charge first (via console or webhook)
- Send a webhook event to create a dispute
- Check that Sidekiq processed the job

## Quick Test Script

```bash
# 1. Create users
bin/rails users:sample

# 2. Create a charge
bin/rails runner "Charge.create!(external_id: 'chg_test', amount_cents: 5000, currency: 'USD')"

# 3. Send webhook to create dispute
./scripts/post_webhook.sh dispute.opened dsp_test chg_test

# 4. Start the app
bin/dev
```

Then visit http://localhost:3000 and sign in with `admin@disputor.local` / `admin123`
