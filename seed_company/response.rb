module Response
  class << self
    def response(response:, status_code: 200)
      {
        statusCode: status_code,
        body: response.to_json
      }
    end

    def success(response)
      response(response: response)
    end

    def bad_request(response)
      response(response: response, status_code: 400)
    end

    def not_found(response)
      response(response: response, status_code: 404)
    end
  end
end
