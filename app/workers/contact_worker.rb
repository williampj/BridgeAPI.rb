class ContactWorker
  include Sidekiq::Worker

  def perform(payload)
    ContactMailer.contact_us(payload)
  end
end
