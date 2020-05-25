require_relative 'spec_helper'

RSpec.describe 'app' do
  let (:event) do
    {
      body: "{\n\t\"ticker\": \"BRKB\"\n}",
      resource: '/{proxy+}',
      path: '/path/to/resource',
      httpMethod: 'POST',
      isBase64Encoded: true,
      queryStringParameters: nil,
      pathParameters: {
        proxy: '/path/to/resource'
      },
      stageVariables: {
        baz: 'qux'
      },
      headers: {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Encoding' => 'gzip, deflate, sdch',
        'Accept-Language' => 'en-US,en;q=0.8',
        'Cache-Control' => 'max-age=0',
        'CloudFront-Forwarded-Proto' => 'https',
        'CloudFront-Is-Desktop-Viewer' => 'true',
        'CloudFront-Is-Mobile-Viewer' => 'false',
        'CloudFront-Is-SmartTV-Viewer' => 'false',
        'CloudFront-Is-Tablet-Viewer' => 'false',
        'CloudFront-Viewer-Country' => 'US',
        'Host' => '1234567890.execute-api.us-east-1.amazonaws.com',
        'Upgrade-Insecure-Requests' => '1',
        'User-Agent' => 'Custom User Agent String',
        'Via' => '1.1 08f323deadbeefa7af34d5feb414ce27.cloudfront.net (CloudFront)',
        'X-Amz-Cf-Id' => 'cDehVQoZnx43VYQb9j2-nvCh-9z396Uhbp027Y2JvkCPNLmGJHqlaA==',
        'X-Forwarded-For' => '127.0.0.1, 127.0.0.2',
        'X-Forwarded-Port' => '443',
        'X-Forwarded-Proto' => 'https'
      },
      requestContext: {
        accountId: '123456789012',
        resourceId: '123456',
        stage: 'prod',
        requestId: 'c6af9ac6-7b61-11e6-9a41-93e8deadbeef',
        requestTime: '09/Apr/2015:12:34:56 +0000',
        requestTimeEpoch: 1428582896000,
        identity: {
          cognitoIdentityPoolId: 'null',
          accountId: 'null',
          cognitoIdentityId: 'null',
          caller: 'null',
          accessKey: 'null',
          sourceIp: '127.0.0.1',
          cognitoAuthenticationType: 'null',
          cognitoAuthenticationProvider: 'null',
          userArn: 'null',
          userAgent: 'Custom User Agent String',
          user: 'null'
        },
        path: '/prod/path/to/resource',
        resourcePath: '/{proxy+}',
        httpMethod: 'POST',
        apiId: '1234567890',
        protocol: 'HTTP/1.1'
      }
    }
  end

  let (:mock_response) do
    Object.new.tap do |mock|
      mock.expects(:code).returns(200)
      mock.expects(:body).returns('1.1.1.1')
    end
  end

  let(:expected_result) do
    {:body=>
       "{\"ticker\":\"BRKB\",\"cik\":\"0000320193\",\"name\":\"Apple Inc.\",\"cusip\":\"037833100\",\"formerNames\":[{\"date\":\"2007-01-04\",\"name\":\"APPLE COMPUTER INC\"},{\"date\":\"1997-07-28\",\"name\":\"APPLE COMPUTER INC/ FA\"},{\"date\":\"2019-08-05\",\"name\":\"APPLE INC\"}],\"assitantDirector\":null,\"sicCode\":\"3571\",\"sicIndustryTitle\":\"ELECTRONIC COMPUTERS\",\"sicListHref\":\"https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&SIC=3571&owner=include&count=40\",\"stateOfIncorporation\":\"CA\",\"stateLocation\":\"CA\",\"stateLocationHref\":\"https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&State=CA&owner=include&count=40\",\"cikHref\":\"https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000320193&owner=include&count=40\",\"businessAddress\":{\"type\":\"business\",\"city\":\"CUPERTINO\",\"state\":\"CA\",\"zip\":\"95014\",\"street1\":\"ONE APPLE PARK WAY\",\"street2\":null,\"phone\":\"(408) 996-1010\"},\"mailingAddress\":{\"type\":\"mailing\",\"city\":\"CUPERTINO\",\"state\":\"CA\",\"zip\":\"95014\",\"street1\":\"ONE APPLE PARK WAY\",\"street2\":null,\"phone\":null}}",
     :headers=>{:"Content-Type"=>"application/json"},
     :statusCode=>200
    }
  end

  let(:brkb_response) do
    {
      :metadata => "company",
      :tradingSymbol => "BRKB",
      :cik => "0001067983",
      :name => "BERKSHIRE HATHAWAY INC",
      :cusip => "084670702",
      :formerNames => [{:date => "1999-01-05", :name => "NBH INC"}],
      :assistantDirector => nil,
      :sicCode => "6331",
      :sicIndustryTitle => "FIRE, MARINE &amp; CASUALTY INSURANCE",
      :sicListHref => "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&SIC=6331&owner=include&count=40",
      :stateOfIncorporation => "DE",
      :stateLocation => "NE",
      :stateLocationHref => "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&State=NE&owner=include&count=40",
      :cikHref => "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0001067983&owner=include&count=40",
      :businessAddress => {:type => "business", :city => "OMAHA", :state => "NE", :zip => "68131", :street1 => "3555 FARNAM STREET", :street2 => nil, :phone => "4023461400"},
      :mailingAddress => {:type => "mailing", :city => "OMAHA", :state => "NE", :zip => "68131", :street1 => "3555 FARNAM STREET", :street2 => nil, :phone => nil}
    }
  end

  it 'test_handler' do
    handler_response = seed_company_handler(event: event, context: '') # creates record
    parsed_response = JSON.parse(handler_response[:body]).deep_symbolize_keys
    expect(parsed_response.except(:updated_at)).to eq brkb_response

    seed_company_handler(event: event, context: '') # merges existing record

    company = Company.find('0001067983')
    filings = Filings.find_by_cik(company.cik)
    company_filings = filings.select {|f| f.is_a?(Company)}
    expect(company.is_a?(Company)).to be
    expect(company.is_a?(Filings)).to be
    expect(filings.count > 0).to be
    expect(company_filings.count).to eq 1 # creates exactly 1 company record
    expect(filings.include?(company)).to be

    company.destroy

    expect { Company.find('0001067983') }.to raise_error do |error|
      expect(error).to be_a Dynamoid::Errors::RecordNotFound
      expect(error.to_s).to eq "Couldn't find Company with primary key (0001067983,company)"
    end
  end
end