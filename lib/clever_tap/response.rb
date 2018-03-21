class CleverTap
  class Response
    attr_accessor :response, :success, :failures

    def initialize(response)
      @response = JSON.parse(response.body)
      process_response
    end

    private

    def process_response
      return process_success if response['status'] == 'success'
      @success = false
      @failures = [response]
    end

    def process_success
      if response['unprocessed'].to_a.empty?
        @success = true
        @failures = []
      else
        @success = false
        @failures = response['unprocessed']
      end
    end
  end
end
