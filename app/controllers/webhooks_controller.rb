class WebhooksController < ApplicationController
  skip_before_action :require_authentication

  def disputes
    payload = params.to_unsafe_h.except(:controller, :action)

    # Basic validation
    unless valid_webhook_payload?(payload)
      return render json: { error: "Invalid payload" }, status: :unprocessable_entity
    end

    # Generate event_id if not provided (for idempotency)
    event_id = payload[:event_id] || SecureRandom.uuid

    # Store webhook event for idempotency
    webhook_event = WebhookEvent.find_or_initialize_by(event_id: event_id)
    if webhook_event.persisted? && webhook_event.processed?
      # Already processed, return success
      return render json: { message: "Event already processed" }, status: :ok
    end

    webhook_event.assign_attributes(
      event_type: payload[:event_type],
      payload: payload,
      dispute_external_id: payload.dig(:dispute, :external_id)
    )

    if webhook_event.save
      # Enqueue job to process the event
      ProcessWebhookEventJob.perform_later(webhook_event.id)
      render json: { message: "Event queued" }, status: :accepted
    else
      render json: { error: webhook_event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def valid_webhook_payload?(payload)
    payload[:event_type].present? &&
      payload.dig(:dispute, :external_id).present? &&
      payload.dig(:dispute, :occurred_at).present?
  end
end
