require 'json'

require 'clever_tap/config'
require 'clever_tap/client'
require 'clever_tap/campaign'
require 'clever_tap/campaign/sms'
require 'clever_tap/campaign/web_push'
require 'clever_tap/campaign/push'
require 'clever_tap/campaign/email'
require 'clever_tap/entity'
require 'clever_tap/event'
require 'clever_tap/profile'
require 'clever_tap/uploader'
require 'clever_tap/campaign_creator'
require 'clever_tap/response'
require 'clever_tap/successful_response'
require 'clever_tap/failed_response'

# the main module of the system
class CleverTap
  attr_reader :config

  class << self
    # Never instantiated.  Variables are stored in the singleton_class.
    private_class_method :new

    attr_accessor :identity_field
    attr_accessor :account_id
    attr_accessor :account_passcode

    def setup
      yield(self)
    end
  end

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

  def create_campaign(campaign)
    response = CampaignCreator.new(campaign).call(client)
    normalize_response(response, records: [campaign])
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
