# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMailer, type: :mailer do
  describe 'contact' do
    let(:email) { described_class.contact('').deliver_now }

    it 'renders the subject' do
      expect(email.subject).to eql('Contact')
    end

    it 'renders the receiver email' do
      expect(email.to).to eql(['test.bridgeapi@gmail.com'])
    end

    it 'renders the sender email' do
      expect(email.from).to eql(['test.bridgeapi@gmail.com'])
    end

    it 'assigns From:' do
      expect(email.body.encoded).to match('From:')
    end

    it 'assigns Message:' do
      expect(email.body.encoded).to match('Message:')
    end
  end
end
