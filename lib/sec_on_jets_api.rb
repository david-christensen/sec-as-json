require "graphql/client"
require "graphql/client/http"

# Star Wars API example wrapper
module SecOnJetsAPI
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  puts "ENV1 ::: #{ENV.inspect}"
  HTTP = GraphQL::Client::HTTP.new(ENV['SEC_ON_JETS_URL']) do
    def headers(context)
      # Optionally set any HTTP headers
      { "Authorization": "Bearer #{ENV['SEC_ON_JETS_API_KEY']}" }
    end
  end

  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  module Company
    QUERY = SecOnJetsAPI::Client.parse <<-'GRAPHQL'
            query($id: String!) {
              company(id: $id) {
                cik,
                name,
                cusip,
                formerNames{date, name},
                assistantDirector,
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
      result = SecOnJetsAPI::Client.query(
        QUERY, variables: {id: id}
      )
      [result&.data&.company, result.errors]
    end
  end
end
