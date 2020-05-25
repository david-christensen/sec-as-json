require 'json'
require 'httparty'
require 'pry'

require 'dotenv'
Dotenv.load('.env.rspec')

require_relative '../lambda_source/app'

begin
  unless HedgeFund.count > 0
    require_relative '../seed_hedge_funds'
  end
rescue Aws::DynamoDB::Errors::ResourceNotFoundException
  require_relative '../dbcreate'
  require_relative '../seed_hedge_funds'
end
