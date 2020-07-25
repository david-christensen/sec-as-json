require 'models'
require 'sec_on_jets_api'
require_relative 'get_company_params'

class GetCompany
  def self.perform(event:, context:)
    params = GetCompanyParams.new(event: event, context: context)
    return params.error_response if params.error_response

    if params.cik
      begin
        company = Company.find(params.cik)
        return Response.not_found(success: false, message: "Couldn't find Company wit cik: #{params.cik}") unless company
      rescue Dynamoid::Errors::RecordNotFound
        return Response.not_found(success: false, message: "Couldn't find Company wit cik: #{params.cik}")
      end
    else
      company = Company.find_by_ticker(params.ticker)
      return Response.not_found(success: false, message: "Couldn't find Company wit ticker: #{params.ticker}") unless company
    end

    Response.success(company)
  end
end
