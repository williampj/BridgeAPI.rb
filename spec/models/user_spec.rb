# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    User.new(
      email: 'mail@mail.com',
      password: 'password'
    )
  end

  it 'is valid when passed a password and valid email' do
    expect(subject).to be_valid
  end

  it 'is invalid without password_digest' do
    subject.password = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without email' do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid with invalid email format' do
    subject.email = 'invalid'
    expect(subject).to_not be_valid
  end

  it 'is invalid with duplicate email at account creation' do
    subject.save
    subject2 = User.new(email: 'mail@mail.com', password: 'password')
    expect(subject2).to_not be_valid
  end

  it 'is invalid if notifications set to nil' do
    subject.notifications = nil
    expect(subject).to_not be_valid
  end
end
