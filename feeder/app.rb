require 'env_from_ssm' if ENV['LAMBDA_ENV'] == 'production'
require_relative 'feeder'

def lambda_handler(event:, context:)
  Feeder.perform(event: event, context: context)
end
