require 'faraday'

module CleverTap
  # Thin wrapper around Faraday, setting URL and headers
  class Client
    DOMAIN = 'https://api.clevertap.com'.freeze
    API_VERSION = 1

    ACCOUNT_HEADER = 'X-CleverTap-Account-Id'.freeze
    PASSCODE_HEADER = 'X-CleverTap-Passcode'.freeze

    attr_accessor :account_id, :passcode

    def initialize(account_id, passcode)
      @account_id = account_id || raise('Clever Tap `account_id` missing')
      @passcode = passcode || raise('Clever Tap `passcode` missing')
    end

    def connection
      # TODO: pass the config to a block
      @connection ||= Faraday.new("#{DOMAIN}/#{API_VERSION}") do |config|
        config.adapter :net_http
        config.headers['Content-Type'] = 'application/json'
        config.headers[ACCOUNT_HEADER] = account_id
        config.headers[PASSCODE_HEADER] = passcode
      end
    end

    def post(*args, &block)
      connection.post(*args, &block)
    end

    def get(*args, &block)
      connection.get(*args, &block)
    end
  end
end
