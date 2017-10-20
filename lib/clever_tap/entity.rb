class CleverTap
  class NoDataError < RuntimeError
    def message
      'No `data` param provided for Event'
    end
  end

  class MissingIdentityError < RuntimeError
    def message
      "Couldn'n find `identity` in CleverTap.config or `data`"
    end
  end

  class Entity
    ALLOWED_IDENTITIES = %w(objectId FBID GPID).freeze
    IDENTITY_STRING = 'identity'.freeze
    TIMESTAMP_STRING = 'ts'.freeze
    TYPE_KEY_STRING = 'type'.freeze
    UPLOAD_LIMIT = 'Needs child class value'.freeze
    TYPE_VALUE_STRING = 'Needs child class value'.freeze

    class << self
      def upload_limit
        self::UPLOAD_LIMIT
      end

      def all_same_type?(items)
        items.all? { |i| i.class == self }
      end
    end

    def initialize(**args)
      @data = args[:data]
      @identity = choose_identity(args)
      @timestamp = choose_timestamp(args)
    end

    def to_h
      put_identity_pair
        .merge(put_timestamp_pair)
        .merge(put_type_pair)
        .merge(put_data)
    end

    private

    def put_identity_pair
      raise NoDataError if @data.to_h.empty?
      raise MissingIdentityError if @identity == '' || @data[@identity].nil?
      return { @identity => @data[@identity].to_s } if allowed?(@identity)
      { IDENTITY_STRING => @data[@identity].to_s }
    end

    def put_timestamp_pair
      return {} unless @timestamp
      { TIMESTAMP_STRING => @timestamp }
    end

    def put_type_pair
      { TYPE_KEY_STRING => self.class::TYPE_VALUE_STRING }
    end

    def put_data
      raise NoDataError if @data.to_h.empty?
      @data.delete(@identity) if allowed?(@identity)
      {
        self.class::DATA_STRING => @data
      }
    end

    def choose_identity(args)
      identity = args[:identity].to_s

      return identity if allowed?(identity) && @data.to_h.key?(identity)
      CleverTap.identity_field.to_s
    end

    def choose_timestamp(args)
      return args[:custom_timestamp].to_i if args[:custom_timestamp]
      return @data.delete(args[:timestamp_field].to_s).to_i if args[:timestamp_field]
    end

    def allowed?(identity)
      ALLOWED_IDENTITIES.include?(identity)
    end
  end
end
