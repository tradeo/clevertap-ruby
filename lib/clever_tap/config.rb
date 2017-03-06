class CleverTap
  # CleverTap instance's config store object
  class Config
    DEFAULT_IDENTITY_FIELD = 'identity'.freeze

    attr_accessor :account_id, :passcode, :identity_field

    def initialize(**config)
      @account_id = config[:account_id]
      @passcode = config[:passcode]
      @identity_field = config[:identity_field] || DEFAULT_IDENTITY_FIELD
      @configure_faraday = config[:configure_faraday]
    end

    # NOTE: reader or writer depending if the block is given
    def configure_faraday(&block)
      block ? @configure_faraday = block : @configure_faraday
    end

    def validate
      raise 'Missing authentication parameter `account_id`' unless account_id
      raise 'Missing authentication parameter `passcode`' unless passcode
    end
  end
end
