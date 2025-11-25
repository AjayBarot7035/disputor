#!/bin/bash

# Script to send sample webhook events to the dispute review queue
# Usage: ./scripts/post_webhook.sh [event_type] [dispute_id] [charge_id]

BASE_URL="${BASE_URL:-http://localhost:3000}"
EVENT_TYPE="${1:-dispute.opened}"
DISPUTE_ID="${2:-dsp_$(date +%s)}"
CHARGE_ID="${3:-chg_$(date +%s)}"

case "$EVENT_TYPE" in
  "dispute.opened")
    curl -X POST "$BASE_URL/webhooks/disputes" \
      -H "Content-Type: application/json" \
      -d "{
        \"event_type\": \"dispute.opened\",
        \"event_id\": \"evt_$(date +%s)\",
        \"dispute\": {
          \"external_id\": \"$DISPUTE_ID\",
          \"charge_external_id\": \"$CHARGE_ID\",
          \"amount_cents\": $((RANDOM % 10000 + 1000)),
          \"currency\": \"USD\",
          \"status\": \"open\",
          \"occurred_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
        }
      }"
    ;;
  "dispute.updated")
    curl -X POST "$BASE_URL/webhooks/disputes" \
      -H "Content-Type: application/json" \
      -d "{
        \"event_type\": \"dispute.updated\",
        \"event_id\": \"evt_$(date +%s)\",
        \"dispute\": {
          \"external_id\": \"$DISPUTE_ID\",
          \"status\": \"needs_evidence\",
          \"occurred_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
        }
      }"
    ;;
  "dispute.closed")
    curl -X POST "$BASE_URL/webhooks/disputes" \
      -H "Content-Type: application/json" \
      -d "{
        \"event_type\": \"dispute.closed\",
        \"event_id\": \"evt_$(date +%s)\",
        \"dispute\": {
          \"external_id\": \"$DISPUTE_ID\",
          \"status\": \"won\",
          \"occurred_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
        }
      }"
    ;;
  *)
    echo "Usage: $0 [dispute.opened|dispute.updated|dispute.closed] [dispute_id] [charge_id]"
    echo "Example: $0 dispute.opened dsp_123 chg_456"
    exit 1
    ;;
esac

echo ""

