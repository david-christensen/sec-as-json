require 'open-uri'

class FormFeed
  def initialize(rss)
    @rss = rss
  end

  def self.from_sec_rss(type = '4')
    @rss = {}
    @feed_pages = []
    begin
      start = 0
      count = 100
      puts "Paging through recent '#{type}' Filings"
      puts "Fetching Page #{(start / 100) + 1 }"
      no_recent_filings = false
      until start == 3000 || no_recent_filings # There appears to be a hard limit at 2000 filings
        url = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&CIK=&type=#{type}&company=&dateb=&owner=include&start=#{start}&count=#{count}&output=atom"
        file = URI.open(url)
        no_recent_filings = file.is_a?(StringIO) && file&.string&.include?('No recent filings') || false
        next if no_recent_filings
        begin
          xml = File.read(file)
        rescue => e
          if file.is_a?(StringIO)
            if file&.string&.include?('<?xml')
              xml = file.string
            else
              puts "Error unable to read file: #{file.string}"
              raise e
            end
          else
            puts "Error unable to read file: #{file}"
            raise e
          end
        end
        @feed_pages << Hash.from_xml(xml)
        start += 100
        puts "Fetching Page #{(start / 100) + 1 }"
      end
    rescue => e
      puts "Uh oh - Unable to parse feed page - #{e} #{e.backtrace.join("\n")}"
      # /done
    ensure
      puts "Done Fetching Recent '#{type}' Filings"
    end

    @rss = @feed_pages.shift

    @feed_pages.each do |page|
      @rss['feed']['entry'] += page['feed']['entry']
    end

    new(@rss)
  end

  def entries
    @rss && @rss.dig('feed', 'entry') || []
  end
end

class Form4Feed < FormFeed
  def self.from_sec_rss
    super('4')
  end

  def entries
    @entries ||= super&.select {|e| ['4', '4/A'].include?(e&.dig('category', 'term')) }
                        .map {|data| Form4Entry.new(data) } || []
  end

  def reported_entries
    entries.select {|e| e.reporting_cik }
  end

  def issued_entries
    entries.select {|e| e.issuer_cik }
  end

  def to_h
    {
      reported_entries: reported_entries.map(&:to_h),
      reported_entry_count: reported_entries.count,
      issued_entries: issued_entries.map(&:to_h),
      issued_entry_count: issued_entries.count
    }
  end
end

class Form13FHRFeed < FormFeed
  def self.from_sec_rss
    super('13F-HR')
  end

  def entries
    @entries ||= super&.select {|e| ['13F-HR'].include?(e&.dig('category', 'term')) }
                   .map {|data| Form13FHREntry.new(data) } || []
  end
end

class FeedEntry

  def initialize(data)
    @data = data
  end

  def title
    @data['title']
  end

  def term
    @data&.dig('category', 'term')
  end

  def label
    @data&.dig('category', 'label')
  end

  def summary
    @data['summary']
  end

  def filing_detail_url
    @data&.dig('link', 'href')
  end

  def sec_accession_number
    filing_detail_url.respond_to?(:match) &&
      filing_detail_url.match(/[0-9]+-[0-9]+-[0-9]+/)&.to_s
  end

  def date_filed
    summary&.match(/Filed:<\/b>\s[0-9]{4}-[0-9]{2}-[0-9]{2}\s/)&.to_s&.match(/[0-9]{4}-[0-9]{2}-[0-9]{2}/).to_s
  end

  def account_number
    summary&.match(/AccNo:<\/b>\s[0-9]+-[0-9]+-[0-9]+\s/)&.to_s&.match(/[0-9]+-[0-9]+-[0-9]+/).to_s
  end

  def document_size_kb
    summary&.match(/Size:<\/b>\s[0-9]+\sKB/)&.to_s&.match(/[0-9]+/)&.to_s&.to_i
  end

  private

  def cik_match(value)
    value.respond_to?(:match) &&
      value.match(/[0-9]{10}/) ||
      false
  end
end

class Form4Entry < FeedEntry
  def to_h
    {
      cik: cik,
      reportingCik: reporting_cik,
      issuerCik: issuer_cik,
      title: title,
      term: term,
      label: label,
      summary: summary,
      filingDetailUrl: filing_detail_url,
      secAccessionNumber: sec_accession_number,
      dateFiled: date_filed,
      accountNumber: account_number,
      documentSizeKb: document_size_kb
    }
  end

  def cik
    reporting_cik || issuer_cik
  end

  def reporting_cik
    @data['title']&.to_s&.length > 0 &&
      @data['title'].match(/\(Reporting\)/) &&
        cik_match(@data['title'])&.to_s
  end

  def issuer_cik
    @data['title']&.to_s&.length > 0 &&
      @data['title'].match(/\(Issuer\)/) &&
        cik_match(@data['title'])&.to_s
  end
end

class Form13FHREntry < FeedEntry

  def cik
    @data['title']&.to_s&.length > 0 &&
      @data['title'].match(/\(Filer\)/) &&
      cik_match(@data['title'])&.to_s
  end

  def to_h
    {
      cik: cik,
      title: title,
      term: term,
      label: label,
      summary: summary,
      filingDetailUrl: filing_detail_url,
      secAccessionNumber: sec_accession_number,
      dateFiled: date_filed,
      accountNumber: account_number,
      documentSizeKb: document_size_kb
    }
  end
end