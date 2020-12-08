require './spec_helper'

RSpec.describe ContactWorker, type: :worker do 
  before_do 
    @payload = contact_payload 
  end
end