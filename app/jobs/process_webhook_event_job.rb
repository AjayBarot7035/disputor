class ProcessWebhookEventJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find(webhook_event_id)

    # Skip if already processed (idempotency check)
    return if webhook_event.processed?

    # JSONB stores keys as strings, so we need to access with string keys or convert
    payload = webhook_event.payload.with_indifferent_access
    dispute_data = payload[:dispute] || {}
    event_type = webhook_event.event_type

    case event_type
    when "dispute.opened"
      process_dispute_opened(dispute_data, webhook_event)
    when "dispute.updated"
      process_dispute_updated(dispute_data, webhook_event)
    when "dispute.closed"
      process_dispute_closed(dispute_data, webhook_event)
    end

    # Mark as processed
    webhook_event.update!(processed: true, processed_at: Time.current)
  end

  private

  def process_dispute_opened(dispute_data, webhook_event)
    charge = Charge.find_by!(external_id: dispute_data[:charge_external_id])

    dispute = Dispute.find_or_initialize_by(external_id: dispute_data[:external_id])
    dispute.assign_attributes(
      charge: charge,
      amount_cents: dispute_data[:amount_cents],
      currency: dispute_data[:currency] || "USD",
      status: dispute_data[:status] || "open",
      opened_at: Time.parse(dispute_data[:occurred_at]),
      external_payload: webhook_event.payload
    )

    dispute.save!
  end

  def process_dispute_updated(dispute_data, webhook_event)
    dispute = Dispute.find_by!(external_id: dispute_data[:external_id])

    # Update status if provided
    if dispute_data[:status].present?
      # Use system user for webhook transitions (or create a system user)
      system_user = User.find_or_create_by!(email: "system@disputor.local") do |u|
        u.password = SecureRandom.hex(32)
        u.role = :admin
        u.time_zone = "UTC"
      end

      dispute.transition_to(dispute_data[:status], actor: system_user, note: "Webhook update")
    end

    # Update external_payload
    dispute.update!(external_payload: webhook_event.payload)
  end

  def process_dispute_closed(dispute_data, webhook_event)
    dispute = Dispute.find_by!(external_id: dispute_data[:external_id])

    system_user = User.find_or_create_by!(email: "system@disputor.local") do |u|
      u.password = SecureRandom.hex(32)
      u.role = :admin
      u.time_zone = "UTC"
    end

    if dispute_data[:status].present?
      dispute.transition_to(dispute_data[:status], actor: system_user, note: "Webhook closed")
    end

    dispute.update!(external_payload: webhook_event.payload)
  end
end
