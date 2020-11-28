require 'env_from_ssm' if ENV['LAMBDA_ENV'] == 'production'
require_relative 'seed_hedge_funds'

def lambda_handler(event:, context:)
  SeedHedgeFunds.perform(event: event, context: context)
end
