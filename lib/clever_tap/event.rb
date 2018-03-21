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

    def to_h
      super.merge(put_event_name_pair)
    end

    private

    def put_event_name_pair
      raise MissingEventNameError if @name.nil?
      { EVENT_NAME_STRING => @name }
    end
  end
end
