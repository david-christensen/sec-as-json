require 'dotenv/load'
require 'json'
require_relative 'db'
require_relative 'response'
require_relative 'sec_on_jets_api'
require_relative 'seed_company_params'

def lambda_handler(event:, context:)
  params = SeedCompanyParams.new(event: event, context: context)
  # Sample pure Lambda function

  # Parameters
  # ----------
  # event: Hash, required
  #     API Gateway Lambda Proxy Input Format
  #     Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

  # context: object, required
  #     Lambda Context runtime methods and attributes
  #     Context doc: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html

  # Returns
  # ------
  # API Gateway Lambda Proxy Output Format: dict
  #     'statusCode' and 'body' are required
  #     # api-gateway-simple-proxy-for-lambda-output-format
  #     Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

  # begin
  #   response = HTTParty.get('http://checkip.amazonaws.com/')
  # rescue HTTParty::Error => error
  #   puts error.inspect
  #   raise error
  # end

  return Response.bad_request(message: "Company ticker must be provided!") unless params.ticker

  company, errors = SecOnJetsAPI::Company.get(id: params.ticker)

  unless company
    # TODO: Log errors
    return Response.not_found(message: "Could not find Company in the SEC Database.")
  end

  company_hash = {'ticker' => params.ticker}.merge(company.to_h)

  company = DB.merge_or_create(company_hash) #TODO: Implement Database

  Response.success(company)
end
