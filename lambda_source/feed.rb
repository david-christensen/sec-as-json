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
      until start == 3000 # There appears to be a hard limit at 2000 filings
        url = "https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&CIK=&type=#{type}&company=&dateb=&owner=only&start=#{start}&count=#{count}&output=atom"
        file = open(url)
        xml = File.read(file)
        @feed_pages << Hash.from_xml(xml)
        start += 100
        puts "Fetching Page #{(start / 100) + 1 }"
      end
    rescue
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
    @rss.dig('feed', 'entry') || []
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
end

class FeedEntry
  private

  def cik_match(value)
    value.respond_to?(:match) &&
      value.match(/[0-9]{10}/) ||
      false
  end
end

class Form4Entry < FeedEntry
  def initialize(data)
    @data = data
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
end
