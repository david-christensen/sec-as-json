require 'models'
require 'response'
require 'sec_graph_api'

class SeedHedgeFunds
  def self.perform(event:, context:)

    hedge_funds = JSON.parse(File.read('13F-HR_funds.json'))

    hedge_funds.each do |data|
      begin
        HedgeFund.create!(data)
        TrackedFiling.create!(type: "4", fundName: data['name'], cik: data['cik'], reported: true)
        TrackedFiling.create!(type: '13F-HR', fundName: data['name'], cik: data['cik'], reported: true)
      rescue Dynamoid::Errors::RecordNotUnique => _e
      end
    end

    Response.success({success: true})
  end
end