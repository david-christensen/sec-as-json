require 'models'
require 'sec_graph_api'
require_relative 'put_filings_params'

class PutFilings
  def self.perform(event:, context:)
    raise 'No cik Provided!' unless event['cik']
    raise 'No Filing \'type\' Provided!' unless event['type']
    cik = event['cik'] # '0001358706'
    type = event['type'] #' 13F-HR'
    puts "Fetching all #{type} Filings for the cik: #{cik}"
    shallow_filings, errors = SecGraphAPI::Filing.get_all_shallow(id: cik, type: type)

    if errors.any?
      puts errors
    end

    puts "Found #{shallow_filings.count} #{type} Filings for the cik: #{cik}"

    puts "Pulling data for each of them."
    filings = []
    count = 0
    shallow_filings.each_with_object(filings) do |shallow_filing, filings|
      puts "Fetching \"#{shallow_filing.title}\" from #{shallow_filing.date}"

      if count < 2
        filing_data, errors = SecGraphAPI::Filing.get_by(id: cik, url: shallow_filing.detail_href)
      else
        errors = [{message: 'soft count reached'}]
      end

      count += 1

      if errors.any?
        puts "WARNING! Skipping \"#{shallow_filing.title}\" from #{shallow_filing.date} due to errors:"
        puts errors
        next
      end

      # filing_data.to_h is frozen, so dup then remove unwanted key
      filing = filing_data.to_h.dup
      filing['document'] = filing['document'].dup
      filing['document'].delete('__typename')

      filings << filing.deep_symbolize_keys
    end


    records = filings.each do |filing_data|
      success, filing = Filing.merge_or_create(filing_data)
      unless success
        puts "Uh-oh! #{filing}"
      end
      success ? filing : nil
    end.compact

    Response.success(records)
  end
end
