require 'env_from_ssm' if ENV['SAM_ENV'] == 'production'
require_relative 'seed_company'

def lambda_handler(event:, context:)
  SeedCompany.perform(event: event, context: context)
end
