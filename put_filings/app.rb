require 'env_from_ssm' if ENV['LAMBDA_ENV'] == 'production'
require_relative 'put_filings'

def lambda_handler(event:, context:)
  PutFilings.perform(event: event, context: context)
end
