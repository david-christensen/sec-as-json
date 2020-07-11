require 'env_from_ssm' if ENV['LAMBDA_ENV'] == 'production'
require_relative 'get_company'

def lambda_handler(event:, context:)
  GetCompany.perform(event: event, context: context)
end
