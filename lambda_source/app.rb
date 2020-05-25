require_relative 'seed_company_params'
require_relative 'seed_company'

def seed_company_handler(event:, context:)
  params = SeedCompanyParams.new(event: event, context: context)
  return params.error_response if params.error_response
  SeedCompany.call(cik: params.cik, ticker: params.ticker)
end
