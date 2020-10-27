class CleverTap
  class Campaign::Sms < Campaign

    # @return [Hash]
    def to_h
      super.merge(content_hash)
    end

    # @return [Hash]
    # @raise [NoContentError] if no content provided or content is invalid
    def content_hash
      raise NoContentError if @content.to_h.empty?
      raise NoContentError unless content_valid?

      { CONTENT => @content }
    end

    private

    # @return [Boolean]
    def content_valid?
      body = @content.to_h['body'] || @content.to_h[:body]
      !body.nil?
    end
  end
end
