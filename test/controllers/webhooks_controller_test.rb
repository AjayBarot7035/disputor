require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should accept dispute.opened event" do
    Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    
    assert_difference "Dispute.count", 1 do
      assert_enqueued_with(job: ProcessWebhookEventJob) do
        post webhooks_disputes_path, params: {
          event_type: "dispute.opened",
          dispute: {
            external_id: "dsp_123",
            charge_external_id: "chg_123",
            amount_cents: 1000,
            currency: "USD",
            status: "open",
            occurred_at: Time.current.iso8601
          }
        }, as: :json
      end
    end

    assert_response :accepted
  end

  test "should accept dispute.updated event" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    assert_enqueued_with(job: ProcessWebhookEventJob) do
      post webhooks_disputes_path, params: {
        event_type: "dispute.updated",
        dispute: {
          external_id: "dsp_123",
          status: "needs_evidence",
          occurred_at: Time.current.iso8601
        }
      }, as: :json
    end

    assert_response :accepted
  end

  test "should accept dispute.closed event" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "awaiting_decision"
    )

    assert_enqueued_with(job: ProcessWebhookEventJob) do
      post webhooks_disputes_path, params: {
        event_type: "dispute.closed",
        dispute: {
          external_id: "dsp_123",
          status: "won",
          occurred_at: Time.current.iso8601
        }
      }, as: :json
    end

    assert_response :accepted
  end

  test "should reject invalid payload" do
    assert_no_difference "Dispute.count" do
      assert_no_enqueued_jobs(only: ProcessWebhookEventJob) do
        post webhooks_disputes_path, params: {
          event_type: "dispute.opened",
          dispute: {
            # Missing required fields
          }
        }, as: :json
      end
    end

    assert_response :unprocessable_entity
  end
end

