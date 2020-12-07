# frozen_string_literal: true

class ContactWorker
  include Sidekiq::Worker

  # @param [{full_name, email, message}] payload - Used to send email
  def perform(payload)
    # binding.pry
    ContactMailer.with(
      full_name: payload['full_name'],
      email: payload['email'],
      message: payload['message'],
      subject: payload['subject']
    ).contact.deliver
  end
end
