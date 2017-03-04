class CleverTap
  # CleverTap instance's config store object
  class Config
    attr_accessor :account_id, :passcode

    def initialize(**config)
      @account_id = config[:account_id]
      @passcode = config[:passcode]
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
