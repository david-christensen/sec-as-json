require 'json'
require_relative 'models'
require_relative 'response'
require_relative 'sec_on_jets_api'
require_relative 'seed_company_params'

class SeedCompany
  def self.handle_event(event:, context:)
    puts "event: #{event}"
    puts "context: #{context}"
    params = SeedCompanyParams.new(event: event, context: context)

    return params.error_response if params.error_response

    company, errors = SecOnJetsAPI::Company.get(id: params.ticker || params.cik)

    unless company
      puts "Errors finding Company: #{errors}"
      return Response.not_found(message: "Could not find Company in the SEC Database.")
    end

    company_hash = {tradingSymbol: params.ticker}.compact.merge(company.to_h).deep_symbolize_keys
    successful, company = Company.merge_or_create(company_hash)

    successful ? Response.success(company) : Response.bad_request(company.errors)
  end
end
