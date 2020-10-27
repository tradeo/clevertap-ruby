class CleverTap

  class CampaignTypeError < RuntimeError
    def message
      'Unknown campaign type'
    end
  end

  # @!attribute [r] campaign
  #   @return [CleverTap::Campaign] Campaign to create
  # @!attribute [r] type
  #   @return [Symbol] Campaign type
  class CampaignCreator
    HTTP_PATH = 'send/'.freeze

    TYPE_SMS = :sms
    TYPE_PUSH = :push
    TYPE_WEBPUSH = :web_push
    TYPE_EMAIL = :email

    CAMPAIGNS_NOTIFICATIONS_ENDPOINTS = {
      TYPE_SMS => 'sms.json',
      TYPE_PUSH => 'push.json',
      TYPE_WEBPUSH => 'webpush.json',
      TYPE_EMAIL => 'email.json'
    }.freeze

    attr_reader :campaign, :type

    # @param campaign [CleverTap::Campaign]
    # @return HTTP response
    def initialize(campaign)
      @campaign = campaign
      @type = type_of(campaign)
    end

    # @param client [CleverTap::Client]
    def call(client)
      uri = HTTP_PATH + CAMPAIGNS_NOTIFICATIONS_ENDPOINTS[type]
      response = client.post(uri, campaign.to_h.to_json)
      parse_response(response)
    end

    private

    # @param campaign [CleverTap::Campaign]
    # @raise [CampaignTypeError]
    def type_of(campaign)
      case campaign
      when CleverTap::Campaign::Sms
        TYPE_SMS
      when CleverTap::Campaign::WebPush
        TYPE_WEBPUSH
      when CleverTap::Campaign::Push
        TYPE_PUSH
      when CleverTap::Campaign::Email
        TYPE_EMAIL
      else
        raise CampaignTypeError
      end
    end

    def parse_response(http_response)
      http_response
    end
  end
end
