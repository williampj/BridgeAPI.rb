class User < ApplicationRecord
  has_secure_password :password
  has_secure_password :recovery_password, validations: false
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :notifications, inclusion: { in: [true, false ]}

  def safe_json 
    {email: self.email, notifications: self.notifications} 
  end
end
