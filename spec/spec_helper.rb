require 'json'
require 'httparty'
require 'pry'

require 'dotenv'
Dotenv.load('.env.rspec')

PROJECT_ROOT = "#{File.realpath(File.dirname(__FILE__))}/../" unless defined? PROJECT_ROOT
$LOAD_PATH.unshift "#{PROJECT_ROOT}/lib"

require 'models'

begin
  unless HedgeFund.count > 0
    require_relative '../seed_hedge_funds'
  end
rescue Aws::DynamoDB::Errors::ResourceNotFoundException
  require_relative '../dbcreate'
  require_relative '../seed_hedge_funds'
end
