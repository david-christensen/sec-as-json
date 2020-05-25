require 'json'
require_relative 'models'
require_relative 'response'
require_relative 'sec_on_jets_api'

class SeedCompany
  def self.call(cik:, ticker: nil)

    company, errors = SecOnJetsAPI::Company.get(id: ticker || cik)

    unless company
      puts "Errors finding Company: #{errors}"
      return Response.not_found(message: "Could not find Company in the SEC Database.")
    end

    company_hash = {tradingSymbol: ticker}.compact.merge(company.to_h).deep_symbolize_keys
    successful, company = Company.merge_or_create(company_hash)

    successful ? Response.success(company) : Response.bad_request(company.errors)
  end
end
