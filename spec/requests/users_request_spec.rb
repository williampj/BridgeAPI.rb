require 'rails_helper'

RSpec.describe "Users", type: :request do
  it 'saves itself' do
    user = User.new(email: 'admin@dev.io', password_hash: BCrypt::Password::create('password'))
    user.save
    expect(User.first).to eq(user)
  end
end
