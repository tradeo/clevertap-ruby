module CleverTap
  # Normalize the success response data to one interface with the failure one
  class SuccessfulResponse
    attr_reader :raw_response, :unprocessed, :message

    # NOTE: raw_response can include processed, unprocessed, status
    def initialize(raw_response = {})
      @raw_response = raw_response
      @unprocessed = raw_response['unprocessed']
      @message = ''
    end

    def errors
      # TODO: handle JSON::ParserError
      unprocessed.map do |response|
        response.merge(
          'record' => JSON.parse(response['record'])
        )
      end
    end

    def status
      case
      when success then 'success'
      when raw_response['processed'].positive? then 'partial'
      else 'fail'
      end
    end

    def success
      errors.empty?
    end
  end
end
