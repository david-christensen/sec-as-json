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
             {"title"=>"4 - RESTORATION HARDWARE INC (0000863821) (Issuer)",
              "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/863821/000110465920086571/0001104659-20-086571-index.htm"},
              "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001104659-20-086571 <b>Size:</b> 4 KB\n",
              "updated"=>"2020-07-24T21:50:06-04:00",
              "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"4"},
              "id"=>"urn:tag:sec.gov,2008:accession-number=0001104659-20-086571"},
             {"title"=>"4 - Brookfield BBP Canadian GP L.P. (0001819104) (Reporting)",
              "link"=>{"rel"=>"alternate", "type"=>"text/html", "href"=>"https://www.sec.gov/Archives/edgar/data/1819104/000114036120016682/0001140361-20-016682-index.htm"},
              "summary"=>"\n <b>Filed:</b> 2020-07-24 <b>AccNo:</b> 0001140361-20-016682 <b>Size:</b> 23 KB\n",
              "updated"=>"2020-07-24T21:39:04-04:00",
              "category"=>{"scheme"=>"https://www.sec.gov/", "label"=>"form type", "term"=>"4"},
              "id"=>"urn:tag:sec.gov,2008:accession-number=0001140361-20-016682"}]}}
  end

  it 'loads the feed' do
    allow(Form4Feed).to receive(:from_sec_rss).and_return(Form4Feed.new(feed_hash))
    handler_response = described_class.perform(event: nil, context: nil)
    expect(handler_response[:headers]).to eq({"Content-Type": "application/json"})
    expect(handler_response[:statusCode]).to eq 200
    response = JSON.parse(handler_response[:body])
    expect(response['reported_entry_count']).to eq(2)
    expect(response['issued_entry_count']).to eq(1)
  end
end
