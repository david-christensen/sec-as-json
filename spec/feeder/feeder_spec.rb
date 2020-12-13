require_relative '../spec_helper'
require_relative '../../feeder/feeder'

RSpec.describe Feeder do
  let(:ticker) { 'BRKB' }
  let (:event) do
    nil
  end

  let(:feed_hash) do
    {"feed"=>
       {"xmlns"=>"http://www.w3.org/2005/Atom",
        "title"=>"Latest Filings - Sat, 25 Jul 2020 10:45:34 EDT",
        "link"=>[{"rel"=>"alternate", "href"=>"/cgi-bin/browse-edgar?action=getcurrent"}, {"rel"=>"self", "href"=>"/cgi-bin/browse-edgar?action=getcurrent"}],
        "id"=>"https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent",
        "author"=>{"name"=>"Webmaster", "email"=>"webmaster@sec.gov"},
        "updated"=>"2020-07-25T10:45:34-04:00",
        "entry"=>
            [{"title"=>"4 - ALBERINI CARLOS (0001173871) (Reporting)",
              "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1173871/000110465920086571/0001104659-20-086571-index.htm"},
              "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001104659-20-086571 <b>Size:</b> 4 KB\n",
              "updated"=>"2020-07-24T21:50:06-04:00",
              "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"4"},
              "id"=>"urn:tag:sec.gov,2008:accession-number=0001104659-20-086571"},
             {"title"=>"4 - OAKTREE CAPITAL MANAGEMENT LP (0000949509) (Issuer)",
              "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/863821/000110465920086571/0001104659-20-086571-index.htm"},
              "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001104659-20-086571 <b>Size:</b> 4 KB\n",
              "updated"=>"2020-07-24T21:50:06-04:00",
              "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"4"},
              "id"=>"urn:tag:sec.gov,2008:accession-number=0001104659-20-086571"},
             {"title"=>"4 - OAKTREE CAPITAL MANAGEMENT LP (0000949509) (Reporting)",
              "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1819104/000114036120016682/0001140361-20-016682-index.htm"},
              "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001140361-20-016682 <b>Size:</b> 23 KB\n",
              "updated"=>"2020-07-24T21:39:04-04:00",
              "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"4"},
              "id"=>"urn:tag:sec.gov,2008:accession-number=0001140361-20-016682"}]}}
  end

  let(:feed_hash2) do
    {
      "feed" => {
        "xmlns"=>"http://www.w3.org/2005/Atom",
        "title"=>"Latest Filings - Sat, 25 Jul 2020 16:10:28 EDT",
        "link"=>[{"rel"=>"alternate", "href"=>"/cgi-bin/browse-edgar?action=getcurrent"}, {"rel"=>"self", "href"=>"/cgi-bin/browse-edgar?action=getcurrent"}],
        "id"=>"https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent",
        "author"=>{"name"=>"Webmaster", "email"=>"webmaster@sec.gov"},
        "updated"=>"2020-07-25T16:10:28-04:00",
        "entry"=> [
          {
            "title"=>"13F-HR - Ziegler Capital Management, LLC (0001307617) (Filer)",
            "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1307617/000108514620001887/0001085146-20-001887-index.htm"},
            "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001085146-20-001887 <b>Size:</b> 196 KB\n",
            "updated"=>"2020-07-24T17:28:53-04:00",
            "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"13F-HR"},
            "id"=>"urn:tag:sec.gov,2008:accession-number=0001085146-20-001887"
          },
          {
            "title"=>"13F-HR - BERKSHIRE HATHAWAY INC (0001067983) (Filer)",
            "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1760263/000108514620001885/0001085146-20-001885-index.htm"},
            "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001085146-20-001885 <b>Size:</b> 24 KB\n",
            "updated"=>"2020-07-24T17:24:02-04:00",
            "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"13F-HR"},
            "id"=>"urn:tag:sec.gov,2008:accession-number=0001085146-20-001885"
          },
          {
            "title"=>"13F-HR - Mechanics Bank Trust Department (0001439743) (Filer)",
            "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1439743/000108514620001886/0001085146-20-001886-index.htm"},
            "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001085146-20-001886 <b>Size:</b> 133 KB\n",
            "updated"=>"2020-07-24T17:15:29-04:00",
            "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"13F-HR"},
            "id"=>"urn:tag:sec.gov,2008:accession-number=0001085146-20-001886"
          }
        ]
      }
    }
  end

  it 'loads the feed' do
    allow(Form4Feed).to receive(:from_sec_rss).and_return(Form4Feed.new(feed_hash))
    allow(Form13FHRFeed).to receive(:from_sec_rss).and_return(Form13FHRFeed.new(feed_hash2))

    handler_response = described_class.perform(event: nil, context: nil)

    expect(handler_response[:headers]).to eq({"Content-Type": "application/json"})
    expect(handler_response[:statusCode]).to eq 200
    response = JSON.parse(handler_response[:body])
    expect(response['filings_reported']).to eq(
      [
        {
          "cik" => "0000949509",
          "reportingCik" => "0000949509",
          "issuerCik" => nil,
          "title" => "4 - OAKTREE CAPITAL MANAGEMENT LP (0000949509) (Reporting)",
          "term" => "4",
          "label" => "form type",
          "summary" => "\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001140361-20-016682 <b>Size:</b> 23 KB\n",
          "filingDetailUrl" => "https://www.sec.gov/Archives/edgar/data/1819104/000114036120016682/0001140361-20-016682-index.htm",
          "secAccessionNumber" => "0001140361-20-016682",
          "dateFiled" => "2020-07-24",
          "accountNumber" => "0001140361-20-016682",
          "documentSizeKb" => 23
        },
        {
          "cik"=>"0001067983",
          "title"=>"13F-HR - BERKSHIRE HATHAWAY INC (0001067983) (Filer)",
          "term"=>"13F-HR",
          "label"=>"form type",
          "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001085146-20-001885 <b>Size:</b> 24 KB\n",
          "filingDetailUrl"=>"https://www.sec.gov/Archives/edgar/data/1760263/000108514620001885/0001085146-20-001885-index.htm",
          "secAccessionNumber"=>"0001085146-20-001885",
          "dateFiled"=>"2020-07-24",
          "accountNumber"=>"0001085146-20-001885",
          "documentSizeKb"=>24
        }
      ]
    )
    expect(response['total_count']).to eq(2)

    reported_filings = ReportedFiling.all.to_a
    expect(reported_filings.count).to eq 2

    reported_filings.find {|f| f.cik == '0001067983' }.tap do |reported_filing|
      expect(reported_filing.cik).to eq '0001067983'
      expect(reported_filing.metadata).to start_with 'reported-filing-'
      expect(reported_filing.type).to eq 'ReportedFiling'
      expect(reported_filing.title).to eq '13F-HR - BERKSHIRE HATHAWAY INC (0001067983) (Filer)'
      expect(reported_filing.term).to eq '13F-HR'
      expect(reported_filing.summary).to eq "\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001085146-20-001885 <b>Size:</b> 24 KB\n"
      expect(reported_filing.filingDetailUrl).to eq "https://www.sec.gov/Archives/edgar/data/1760263/000108514620001885/0001085146-20-001885-index.htm"
      expect(reported_filing.label).to eq "form type"
      expect(reported_filing.secAccessionNumber).to eq "0001085146-20-001885"
      expect(reported_filing.dateFiled).to eq "2020-07-24"
    end

    reported_filings.find {|f| f.cik == '0000949509' }.tap do |reported_filing|
      expect(reported_filing.cik).to eq '0000949509'
      expect(reported_filing.reportingCik).to eq '0000949509'
      expect(reported_filing.metadata).to start_with 'reported-filing-'
      expect(reported_filing.type).to eq 'ReportedFiling'
      expect(reported_filing.title).to eq '4 - OAKTREE CAPITAL MANAGEMENT LP (0000949509) (Reporting)'
      expect(reported_filing.term).to eq '4'
      expect(reported_filing.summary).to eq "\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001140361-20-016682 <b>Size:</b> 23 KB\n"
      expect(reported_filing.filingDetailUrl).to eq "https://www.sec.gov/Archives/edgar/data/1819104/000114036120016682/0001140361-20-016682-index.htm"
      expect(reported_filing.label).to eq "form type"
      expect(reported_filing.secAccessionNumber).to eq "0001140361-20-016682"
      expect(reported_filing.dateFiled).to eq "2020-07-24"
    end

    reported_filings.each {|f| f.destroy}
  end
end
