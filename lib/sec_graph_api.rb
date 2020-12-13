require "graphql/client"
require "graphql/client/http"

# Star Wars API example wrapper
module SecGraphAPI
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new(ENV['SEC_GRAPH_URL']) do
    def headers(context)
      # Optionally set any HTTP headers
      { "Authorization": "Bearer #{ENV['SEC_GRAPH_API_KEY']}" }
    end
  end

  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  module Company
    QUERY = SecGraphAPI::Client.parse <<-'GRAPHQL'
            query($id: String!) {
              company(id: $id) {
                cik,
                name,
                cusip,
                formerNames{date, name},
                assitantDirector,
                sicCode,
                sicIndustryTitle,
                sicListHref,
                stateOfIncorporation,
                stateLocation,
                stateLocationHref,
                cikHref,
                businessAddress{type, city, state, zip street1, street2, phone},
                mailingAddress{type, city, state, zip street1, street2, phone}
              }
            }
          GRAPHQL

    def self.get(id:)
      result = SecGraphAPI::Client.query(
        QUERY, variables: {id: id}
      )
      [result&.data&.company, result.errors]
    end
  end

  module Filing
    URL_QUERY = SecGraphAPI::Client.parse <<-'GRAPHQL'
            query($id: String!,$url: String!) {
              filingByLink(id: $id, link: $url) {
                filerCik,
                title,
                summary, 
                document{
                ... on Form13FHr {
                        type,
                        holdings {
                          nameOfIssuer,
                          cusip,
                          marketValue,
                          titleOfClass,
                          sharesOrPrincipal{amount, type},
                          investmentDiscretion,
                          votingAuthority{sole,shared,none}
                        }
                }
                ... on Form4 {
                        type, periodOfReport, subjectToSection16, 
                        issuer {cik, name, tradingSymbol},
                        reportingOwner {
                          cik, name, isOfficer, officerTitle, isDirector, isOther, otherText,
                          address {street1, street2, city, state,zip, stateDescription}
                        },
                        securities {type, transactionDate,coding{formType,code,equitySwapInvolved},
                        amounts {shares, pricePerShare, acquiredDisposedCode},postTransactionAmounts{sharesOwned},
                        ownershipNature {directOrIndirectOwnership}},
                        footnotes,
                        remarks
                      }
                },
                detailHref,
                type,
                date,
                secAccessionNumber
              }
            }
          GRAPHQL


    GET_ALL_SHALLOW_QUERY = SecGraphAPI::Client.parse <<-'GRAPHQL'
            query($id: String!,$type: String!) {
              allFilings(id: $id, type: $type) {
                filerCik,
                title,
                summary, 
                detailHref,
                type,
                date,
                secAccessionNumber
              }
            }
    GRAPHQL


    def self.get_by(id:, url:)
      result = SecGraphAPI::Client.query(
        URL_QUERY, variables: {id: id, url: url}
      )
      [result&.data&.filing_by_link, result.errors]
    end

    def self.get_all_shallow(id:, type:)
      result = SecGraphAPI::Client.query(
        GET_ALL_SHALLOW_QUERY, variables: {id: id, type: type}
      )
      [result&.data&.all_filings, result.errors]
    end
  end
end
