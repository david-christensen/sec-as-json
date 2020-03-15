class SeedCompanyParams
  def initialize(event:, context:)
    @event = event
    @context = context
  end

  def ticker
    @ticker ||= @event.dig(:queryStringParameters, :ticker)
  end
end
