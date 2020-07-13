require 'json'
require 'dotenv/load'
require 'pry'

require_relative 'lib/models'

hedge_funds = JSON.parse(File.read('13F-HR_funds.json'))

hedge_funds.each do |data|
  begin
    HedgeFund.create!(data)
    TrackedFiling.create!(type: '4', fund_name: data['name'], cik: data['cik'])
    TrackedFiling.create!(type: '13F-HR', fund_name: data['name'], cik: data['cik'])
  rescue Dynamoid::Errors::RecordNotUnique => _e
  end
end
