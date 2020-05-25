require 'json'
require 'httparty'
require 'mocha/test_unit'
require 'pry'
require 'dotenv/load'

require_relative '../lambda_source/app'

begin
  unless HedgeFund.count > 0
    require_relative '../seed_hedge_funds'
  end
rescue Aws::DynamoDB::Errors::ResourceNotFoundException
  require_relative '../dbcreate'
  require_relative '../seed_hedge_funds'
end
