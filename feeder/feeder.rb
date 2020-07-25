require_relative 'feed'
require 'response'

class Feeder
  def self.perform(event:, context:)
    feed = Form4Feed.from_sec_rss

    tracked_filing_map = TrackedFiling.partitioned_reported

    reported = feed.reported_entries.each_with_object([]) do |entry, found|
      tracked = tracked_filing_map[entry.term]&.find {|t| t.cik == entry.cik}
      if tracked
        puts "Form #{entry.term} Filing Reported by #{tracked.fundName}"
        found << entry
      end
    end

    feed = Form13FHRFeed.from_sec_rss

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

    reported.each do |data|
      ReportedFiling.create!(data.to_h)
    end

    Response.success(response)
  end
end