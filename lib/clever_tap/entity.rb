class CleverTap
  class NoDataError < RuntimeError
    def message
      'No `data` param provided for Event'
    end
  end

  class MissingIdentityError < RuntimeError
    def message
      "Couldn't find `identity` in CleverTap.config or `data`"
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

      # @return [Boolean]
      def all_same_type?(items)
        items.all? { |i| i.class == self }
      end
    end

    def initialize(**args)
      @data = args[:data]
      @identity = choose_identity(args)
      @timestamp = choose_timestamp(args)
    end

    # @return [Hash]
    def to_h
      identity_hash
        .merge(timestamp_hash)
        .merge(type_hash)
        .merge(data_hash)
    end

    private

    # @return [Hash]
    def identity_hash
      raise NoDataError if @data.to_h.empty?
      raise MissingIdentityError if @identity == '' || @data[@identity].nil?
      return { @identity => @data[@identity].to_s } if allowed?(@identity)

      { IDENTITY_STRING => @data[@identity].to_s }
    end

    # @return [Hash]
    def timestamp_hash
      return {} unless @timestamp

      { TIMESTAMP_STRING => @timestamp }
    end

    # @return [Hash]
    def type_hash
      { TYPE_KEY_STRING => self.class::TYPE_VALUE_STRING }
    end

    # @return [Hash]
    def data_hash
      raise NoDataError if @data.to_h.empty?

      @data.delete(@identity) if allowed?(@identity)
      {
        self.class::DATA_STRING => @data
      }
    end

    # @return [String]
    def choose_identity(args)
      identity = args[:identity].to_s
      return identity if allowed?(identity) && @data.to_h.key?(identity)

      CleverTap.identity_field.to_s
    end

    # @return [Integer, nil]
    def choose_timestamp(args)
      return args[:custom_timestamp].to_i if args[:custom_timestamp]

      @data.delete(args[:timestamp_field].to_s).to_i if args[:timestamp_field]
    end

    # @return [Boolean]
    def allowed?(identity)
      ALLOWED_IDENTITIES.include?(identity)
    end
  end
end
