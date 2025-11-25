class CaseAction < ApplicationRecord
  belongs_to :dispute
  belongs_to :actor, class_name: "User", foreign_key: "actor_id"

  validates :action, presence: true
end
