# frozen_string_literal: true

require 'rails_helper'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../../../support/lib/bridge_api/http/mock_deconstructor'
require_relative '../../../support/lib/bridge_api/http/mock_builders'
require_relative '../../../support/lib/bridge_api/http/mock_formatter'
require_relative '../../../support/lib/bridge_api/http/mock_request_handler'

require_relative '../../../support/lib/bridge_api/syntax_parser/mock_headers_parser'
require_relative '../../../support/lib/bridge_api/syntax_parser/mock_payload_parser'
