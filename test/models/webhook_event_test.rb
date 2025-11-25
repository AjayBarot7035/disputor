require "test_helper"

class WebhookEventTest < ActiveSupport::TestCase
  test "should require event_id" do
    webhook_event = WebhookEvent.new
    assert_not webhook_event.valid?
    assert_includes webhook_event.errors[:event_id], "can't be blank"
  end

  test "should require unique event_id" do
    WebhookEvent.create!(event_id: "evt_123", event_type: "dispute.opened", payload: {})

    webhook_event = WebhookEvent.new(event_id: "evt_123", event_type: "dispute.opened", payload: {})
    assert_not webhook_event.valid?
    assert_includes webhook_event.errors[:event_id], "has already been taken"
  end

  test "should require event_type" do
    webhook_event = WebhookEvent.new(event_id: "evt_123")
    assert_not webhook_event.valid?
    assert_includes webhook_event.errors[:event_type], "can't be blank"
  end
end
