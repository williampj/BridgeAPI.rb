# frozen_string_literal: true

class ContactWorker
  include Sidekiq::Worker

  # @param [{full_name, email, message}] payload - Used to send email
  def perform(payload)
    ContactMailer.contact_us(payload).deliver
  end
end
