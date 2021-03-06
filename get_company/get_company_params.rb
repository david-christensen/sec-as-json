require 'json'
require 'response'

class GetCompanyParams
  def initialize(event:, context:)
    @event = event
    @context = context
  end

  def json_body
    begin
      JSON.parse(@event.dig(:body)&.gsub("\\n", '')&.gsub("\\t", '')&.gsub("\\", '')) if  @event.dig(:body)
    end ||
      begin
        JSON.parse(@event.dig('body')&.gsub("\\n", '')&.gsub("\\t", '')&.gsub("\\", '')) if  @event.dig('body')
      end || {}
  end

  def ticker
    return @ticker if @ticker
    value = (@event.dig('pathParameters', 'ticker') || json_body['ticker'])&.upcase
    @ticker = value.is_a?(String) && value.presence || nil
  end

  def cik
    return @cik if @cik
    value = (@event.dig('pathParameters', 'cik') || json_body['cik'])
    @cik = value.is_a?(String) && value.presence || nil
  end

  def cik_valid?
    cik.match(/^[0-9]{10}$/)
  end

  def ticker_valid?
    ticker.match /^[A-Z]{1,5}$/
  end

  def error_response
    return Response.bad_request(message: "Company ticker or cik must be provided!") unless ticker || cik
    return Response.bad_request(message: "Invalid Company ticker provided!") if ticker && !ticker_valid?
    return Response.bad_request(message: "Invalid Company cik provided!") if cik && !cik_valid?
    nil
  end
end
