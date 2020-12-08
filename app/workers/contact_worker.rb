# frozen_string_literal: true

class ContactWorker
  include Sidekiq::Worker

  # @param [{full_name, email, message, subject}] payload - Used to send email
  def perform(payload)
    ContactMailer.contact(payload).deliver
  end
end
