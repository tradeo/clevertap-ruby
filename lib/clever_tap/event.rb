class CleverTap
  class MissingEventNameError < RuntimeError
    def message
      "Couldn't find `name:` with value in Event#new(options)"
    end
  end

  class Event < Entity
    DATA_STRING = 'evtData'.freeze
    EVENT_NAME_STRING = 'evtName'.freeze
    TYPE_VALUE_STRING = 'event'.freeze
    UPLOAD_LIMIT = 1000

    def initialize(**args)
      super(**args)
      @name = args[:name]
    end

    # @return [Hash]
    def to_h
      super.merge(event_name_hash)
    end

    private

    # @return [Hash]
    def event_name_hash
      raise MissingEventNameError if @name.nil?

      { EVENT_NAME_STRING => @name }
    end
  end
end
