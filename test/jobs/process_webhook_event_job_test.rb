require "test_helper"

class ProcessWebhookEventJobTest < ActiveJob::TestCase
  test "should process dispute.opened event" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    webhook_event = WebhookEvent.create!(
      event_id: "evt_123",
      event_type: "dispute.opened",
      payload: {
        dispute: {
          external_id: "dsp_123",
          charge_external_id: "chg_123",
          amount_cents: 1000,
          currency: "USD",
          status: "open",
          occurred_at: Time.current.iso8601
        }
      }
    )

    assert_difference "Dispute.count", 1 do
      ProcessWebhookEventJob.perform_now(webhook_event.id)
    end

    dispute = Dispute.last
    assert_equal "dsp_123", dispute.external_id
    assert_equal charge, dispute.charge
    assert_equal "open", dispute.status
    assert webhook_event.reload.processed?
  end

  test "should be idempotent" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    webhook_event = WebhookEvent.create!(
      event_id: "evt_123",
      event_type: "dispute.opened",
      payload: {
        dispute: {
          external_id: "dsp_123",
          charge_external_id: "chg_123",
          amount_cents: 1000,
          currency: "USD",
          status: "open",
          occurred_at: Time.current.iso8601
        }
      },
      processed: true
    )

    assert_no_difference "Dispute.count" do
      ProcessWebhookEventJob.perform_now(webhook_event.id)
    end
  end
end

