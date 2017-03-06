$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'clever_tap'

require 'vcr'
require 'vcr_config'

require 'factories/profile'
require 'pry-byebug'

# Use for recording VCR cassettes
AUTH_ACCOUNT_ID = ENV['CLEVER_TAP_ACCOUNT_ID'] || 'fake-id'
AUTH_PASSCODE = ENV['CLEVER_TAP_PASSCODE'] || 'fake-passcode'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.mock_with(:rspec) { |c| c.syntax = :expect }
end
