# frozen_string_literal: true

require 'rails_helper'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../../../support/lib/bridge_api/http/mock_deconstructor'
