require 'json'

require 'clever_tap/client'
require 'clever_tap/uploader'
require 'clever_tap/successful_response'
require 'clever_tap/failed_response'

# the main module of the system
module CleverTap
  class << self
    attr_accessor :config

    # TODO: possibility for adding a logger
    def configure(account_id:, passcode:, **rest)
      @config ||= rest.merge(account_id: account_id, passcode: passcode).freeze
    end

    def upload_event(events, name:, identity_field:, **rest)
      events = events.is_a?(Array) ? events : [events]
      options = rest.merge(event_name: name, identity_field: identity_field)

      response = Uploader.new(events, options).call(client)

      normalize_response(response, records: events)
    rescue Faraday::Error::TimeoutError, Faraday::Error::ClientError => e
      FailedResponse.new(records: events, message: e.message)
    end

    def upload_profile(profiles, **options)
      profiles = profiles.is_a?(Array) ? profiles : [profiles]

      response = Uploader.new(profiles, **options).call(client)

      normalize_response(response, records: profiles)
    rescue Faraday::Error::TimeoutError, Faraday::Error::ClientError => e
      FailedResponse.new(records: profiles, message: e.message)
    end

    def client
      @client ||= Client.new(config[:account_id], config[:passcode])
    end

    private

    def normalize_response(response, records:)
      # TODO: handle JSON::ParserError
      if response.success?
        SuccessfulResponse.new(JSON.parse(response.body))
      else
        FailedResponse.new(records: records, code: response.status, message: response.body)
      end
    end
  end
end
