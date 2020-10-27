class CleverTap
  class Campaign::WebPush < Campaign

    # @return [Hash]
    def to_h
      super.merge(content_hash)
    end

    # @return [Hash]
    # @raise [NoContentError] if no content provided or content is invalid
    def content_hash
      raise NoContentError if @content.to_h.empty?
      raise NoContentError unless content_valid?

      platform_specific = platform_specific_hash
      @content.merge!(platform_specific) unless platform_specific.empty?

      { CONTENT => @content }
    end

    # @return [Hash]
    def platform_specific_hash
      return {} unless @platform_specific

      { PLATFORM_SPECIFIC => @platform_specific }
    end

    private

    # @return [Boolean]
    def content_valid?
      body = @content.to_h['body'] || @content.to_h[:body]
      title = @content.to_h['title'] || @content.to_h[:title]

      !(body.nil? || title.nil?)
    end
  end
end
