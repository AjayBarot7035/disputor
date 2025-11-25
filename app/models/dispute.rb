class Dispute < ApplicationRecord
  belongs_to :charge

  validates :external_id, presence: true, uniqueness: true
end

