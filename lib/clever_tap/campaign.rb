class CleverTap
  class NoContentError < RuntimeError
    def message
      'No `content` param provided for Campaign'
    end
  end

  class NoReceiversError < RuntimeError
    def message
      'No `to` param provided for Campaign'
    end
  end

  class InvalidIdentityTypeError < RuntimeError
    def message
      'The identities types are not valid for Campaigns'
    end
  end

  class ReceiversLimitExceededError < RuntimeError
    def message
      'The max users per campaign limit was exceeded'
    end
  end

  class NoChannelIdError < RuntimeError
    def message
      'Channel Id (wzrk_cid) must be sent'
    end
  end

  # @!attribute to
  #   @return [Hash{String=>Array}] list of receivers
  class Campaign
    ALLOWED_IDENTITIES = %w[FBID Email Identity objectId GPID ID].freeze
    TO_STRING = 'to'.freeze
    TAG_GROUP = 'tag_group'.freeze
    CAMPAIGN_ID = 'campaign_id'.freeze
    CONTENT = 'content'.freeze
    PROVIDER_NICK_NAME = 'provider_nick_name'.freeze
    NOTIFICATION_SENT = 'notification_sent'.freeze
    RESPECT_FREQUENCY_CAPS = 'respect_frequency_caps'.freeze
    WZRK_CID = 'wzrk_cid'.freeze
    BADGE_ID = 'badge_id'.freeze
    BADGE_ICON = 'badge_icon'.freeze
    MUTABLE_CONTENT = 'mutable-content'.freeze
    PLATFORM_SPECIFIC = 'platform_specific'.freeze
    MAX_USERS_PER_CAMPAIGN = 1000

    attr_accessor :to

    # @param to [Hash{String=>Array}] List of receivers' identities grouped by type
    # @param content [Hash{String=>Array] Content hash
    def initialize(to:,
                   content:,
                   tag_group: nil,
                   campaign_id: nil,
                   provider_nick_name: nil,
                   notification_sent: nil,
                   respect_frequency_caps: nil,
                   wzrk_cid: nil,
                   badge_id: nil,
                   badge_icon: nil,
                   mutable_content: nil,
                   platform_specific: nil)
      @to = to
      @tag_group = tag_group
      @campaign_id = campaign_id
      @content = content
      @provider_nick_name = provider_nick_name
      @notification_sent = notification_sent
      @respect_frequency_caps = respect_frequency_caps
      @wzrk_cid = wzrk_cid
      @badge_id = badge_id
      @badge_icon = badge_icon
      @mutable_content = mutable_content
      @platform_specific = platform_specific || content_platform_specific
    end

    # @return [Hash]
    def to_h
      receivers_hash
        .merge(tag_group_hash)
        .merge(provider_nick_name_hash)
        .merge(notification_sent_hash)
        .merge(respect_frequency_caps_hash)
        .merge(badge_id_hash)
        .merge(badge_icon_hash)
        .merge(mutable_content_hash)
    end

    # @return [Hash]
    def receivers_hash
      raise NoReceiversError if empty_receivers?
      raise InvalidIdentityTypeError unless allowed?(@to.keys)
      raise ReceiversLimitExceededError if receivers_limit_exceeded?

      { TO_STRING => @to }
    end

    # @return [Hash]
    def tag_group_hash
      return {} unless @tag_group

      { TAG_GROUP => @tag_group }
    end

    # @return [Hash]
    def campaign_id_hash
      return {} unless @campaign_id

      { CAMPAIGN_ID => @campaign_id }
    end

    # @return [Hash]
    def content_hash
      raise NotImplementedError
    end

    # @return [Hash]
    def provider_nick_name_hash
      return {} unless @provider_nick_name

      { PROVIDER_NICK_NAME => @provider_nick_name }
    end

    # @return [Hash]
    def notification_sent_hash
      return {} unless @notification_sent

      { NOTIFICATION_SENT => @notification_sent }
    end

    # @return [Hash]
    def respect_frequency_caps_hash
      return {} if @respect_frequency_caps.nil?

      { RESPECT_FREQUENCY_CAPS => @respect_frequency_caps }
    end

    # @return [Hash]
    def wzrk_cid_hash
      return {} unless @wzrk_cid

      { WZRK_CID => @wzrk_cid }
    end

    # @return [Hash]
    def badge_id_hash
      return {} unless @badge_id

      { BADGE_ID => @badge_id }
    end

    # @return [Hash]
    def badge_icon_hash
      return {} unless @badge_icon

      { BADGE_ICON => @badge_icon }
    end

    # @return [Hash]
    def mutable_content_hash
      return {} if @mutable_content.nil?

      { MUTABLE_CONTENT => @mutable_content }
    end

    # @return [Hash]
    def content_platform_specific
      @platform_specific ||= @content[:platform_specific]
      @platform_specific ||= @content['platform_specific']
    end

    # @return [Boolean]
    def empty_receivers?
      @to.to_h.empty? || @to.values.all?(&:empty?)
    end

    # @return [Boolean]
    def receivers_limit_exceeded?
      @to.values.map(&:size).reduce(&:+) > MAX_USERS_PER_CAMPAIGN
    end

    # @return [Boolean]
    def allowed?(indentities)
      (indentities - ALLOWED_IDENTITIES).empty?
    end
  end
end
