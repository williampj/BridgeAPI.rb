class ContactWorker
  include Sidekiq::Worker

  # @param [{full_name, email, message}] payload - Used to send email
  def perform(payload)
    binding.pry
    ContactUsMailer.with(
      full_name: payload['full_name'],
      email: payload['email'],
      message: payload['message'],
      subject: payload['subject']
    ).contact_us.deliver
  end
end
