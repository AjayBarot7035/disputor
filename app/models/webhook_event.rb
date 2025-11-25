class WebhookEvent < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :event_type, presence: true

  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }
end
