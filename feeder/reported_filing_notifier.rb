require 'aws-sdk-sns'
require 'json'

class ReportedFilingNotifier
  class << self

    # reported_filings is an array of items like:
    # {:cik=>"0000949509",
    #  :reportingCik=>"0000949509",
    #  :issuerCik=>nil,
    #  :title=>"4 - OAKTREE CAPITAL MANAGEMENT LP (0000949509) (Reporting)",
    #  :term=>"4",
    #  :label=>"form type",
    #  :summary=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001140361-20-016682 <b>Size:</b> 23 KB\n",
    #  :filingDetailUrl=>"https://www.sec.gov/Archives/edgar/data/1819104/000114036120016682/0001140361-20-016682-index.htm",
    #  :secAccessionNumber=>"0001140361-20-016682",
    #  :dateFiled=>"2020-07-24",
    #  :accountNumber=>"0001140361-20-016682",
    #  :documentSizeKb=>23,
    #  :metadata=>"reported-filing-0001140361-20-016682"}
    def perform(reported_filings:)
      unless ENV['REPORTED_FILINGS_TOPIC']
        puts "No 'Reported Filing Topic' registered. Message will not be delivered."
        return
      end

      unless reported_filings.is_a?(Array) && reported_filings.any?
        puts "No Reported Filings provided. Message will not be delivered."
        return
      end

      sns = Aws::SNS::Client.new(region: 'us-east-2') #TODO load region dynamically

      sns.publish(
        {
          target_arn: ENV['REPORTED_FILINGS_TOPIC'],
          message: {
            default: build_message(reported_filings),
            lambda: {reported_filings: reported_filings} # TODO: this doesn't seem to work (looks like SNS is using the default: message for lambda subscriptions)
          }.to_json, # required
          subject: "New Filing(s) Reported",
          message_structure: 'json'
        }
      )
    end

    private

    def build_message(reported_filings)
      message = "The following filings were reported: \n"
      reported_filings.each do |filing|
        message += "\n#{filing[:title]}\n"
        message += "#{filing[:filingDetailUrl]}\n"
      end
      message += "\n"
      message
    end
  end
end