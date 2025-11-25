class User < ApplicationRecord
  has_secure_password

  enum :role, {
    admin: 0,
    reviewer: 1,
    read_only: 2
  }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

