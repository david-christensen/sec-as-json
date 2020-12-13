require_relative 'feed'
require_relative 'reported_filing_notifier'
require 'response'
require 'models'

class Feeder
  def self.perform(event:, context:)
    feed = Form4Feed.from_sec_rss

    tracked_filing_map = TrackedFiling.partitioned_reported

    if feed.reported_entries.any?
      puts "#{feed.reported_entries.count} Form4(s) reported."
    else
      puts "No Form4s reported."
    end

    reported = feed.reported_entries.each_with_object([]) do |entry, found|
      tracked = tracked_filing_map[entry.term]&.find {|t| t.cik == entry.cik}
      if tracked
        puts "Form #{entry.term} Filing Reported by #{tracked.fundName}"
        found << entry
      end
    end

    feed = Form13FHRFeed.from_sec_rss

    if feed.entries.any?
      puts "#{feed.entries.count} Form13HR(s) Found."
    else
      puts "No Form13HR Found."
    end

    feed.entries.each_with_object(reported) do |entry, found|
      tracked = tracked_filing_map[entry.term]&.find {|t| t.cik == entry.cik}
      if tracked
        puts "Form #{entry.term} Filing Reported by #{tracked.fundName}"
        found << entry
      end
    end

    response = {
      filings_reported: reported.map(&:to_h),
      total_count: reported.count
    }

    pp response

    new_reported_filings = []
    reported.each do |entry|
      data = entry.to_h
      data[:metadata] = "reported-filing-#{(data[:secAccessionNumber] || SecureRandom.uid)}"
      begin
        ReportedFiling.create!(data)
        new_reported_filings << data
      rescue Dynamoid::Errors::RecordNotUnique => _e
        puts "Skipping, as record already exists for data: #{data}."
      end
    end

    if new_reported_filings.any?
      ReportedFilingNotifier.perform(reported_filings: new_reported_filings)
    end

    Response.success(response)
  end
end