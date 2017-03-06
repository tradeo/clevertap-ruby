class CleverTap
  # CleverTap instance's config store object
  class Config
    PROFILE_IDENTITY_FIELD_DEFAULT = 'identity'.freeze
    EVENT_IDENTITY_FIELD_DEFALT = 'identity'.freeze

    attr_accessor :account_id, :passcode,
                  :profile_identity_field, :profile_date_field,
                  :event_identity_field

    def initialize(**config)
      @account_id = config[:account_id]
      @passcode = config[:passcode]
      @configure_faraday = config[:configure_faraday]

      @profile_identity_field = config[:profile_identity_field] || PROFILE_IDENTITY_FIELD_DEFAULT
      @profile_date_field = config[:profile_date_field]

      @event_identity_field = config[:event_identity_field] || EVENT_IDENTITY_FIELD_DEFALT
      @events_identity_fields = config[:events_identity_fields] || {}
    end

    # NOTE: reader or writer depending if the block is present
    def configure_faraday(&block)
      block ? @configure_faraday = block : @configure_faraday
    end

    # NOTE: reader or writer depending if the value is present
    def event_identity_field_for(type, value = nil)
      if value
        @events_identity_fields[type] = value
      else
        @events_identity_fields[type] || event_identity_field
      end
    end

    def validate
      raise 'Missing authentication parameter `account_id`' unless account_id
      raise 'Missing authentication parameter `passcode`' unless passcode
    end
  end
end
