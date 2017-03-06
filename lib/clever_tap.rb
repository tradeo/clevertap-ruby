require 'json'

require 'clever_tap/config'
require 'clever_tap/client'
require 'clever_tap/uploader'
require 'clever_tap/successful_response'
require 'clever_tap/failed_response'

# the main module of the system
class CleverTap
  attr_reader :config

  def initialize(**params)
    @config = Config.new(params)
    yield(@config) if block_given?

    @config.validate
    @config.freeze
  end

  def client
    @client ||= Client.new(config.account_id, config.passcode, &config.configure_faraday)
  end

  def upload_events(events, name:, **rest)
    options = rest.merge(event_name: name, identity_field: config.identity_field)

    response = Uploader.new(events, options).call(client)

    normalize_response(response, records: events)
  rescue Faraday::Error::TimeoutError, Faraday::Error::ClientError => e
    FailedResponse.new(records: events, message: e.message)
  end

  def upload_event(event, **options)
    upload_events([event], options)
  end

  def upload_profiles(profiles, **options)
    options = options.merge(identity_field: config.identity_field)
    response = Uploader.new(profiles, **options).call(client)

    normalize_response(response, records: profiles)
  rescue Faraday::Error::TimeoutError, Faraday::Error::ClientError => e
    FailedResponse.new(records: profiles, message: e.message)
  end

  def upload_profile(profile, **options)
    upload_profiles([profile], options)
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
