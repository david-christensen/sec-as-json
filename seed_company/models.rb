require 'dynamoid'
require 'pry'
Dynamoid.configure do |config|
  # To namespace tables created by Dynamoid from other tables you might have.
  # Set to nil to avoid namespacing.
  config.namespace = nil

  # [Optional]. If provided, it communicates with the DB listening at the endpoint.
  # This is useful for testing with [DynamoDB Local] (http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html).
  config.endpoint = 'http://localhost:8000'
end

module Dynamoid::Document
  module ClassMethods
    def choose_right_class(attrs)
      return self unless attrs[inheritance_field]
      klass_name = attrs[inheritance_field].gsub(/-[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/, '').split('-').map{|str| str.capitalize}.join

      # attrs[inheritance_field] ? attrs[inheritance_field].constantize : self
      klass_name&.constantize || self
    end
  end
end

class JsonArray
  def self.dynamoid_dump(json_array)
    json_array.to_json
  end

  def self.dynamoid_load(serialized_str)
    JSON.parse(serialized_str).each(&:deep_symbolize_keys!)
  end
end

class Filings
  include Dynamoid::Document

  table name: :filings, key: :cik, read_capacity: 5, write_capacity: 5, inheritance_field: :metadata
  range :metadata

  def self.find_by_cik(cik)
    chain = where(cik: cik)
    chain.query.reject! {|k, _v| k == :"metadata.in"}
    filings = chain.all
  end

  def constantize(camel_cased_word)
    binding.pry
    super(camel_cased_word.split('-').first.capitalize)
  end
end

class Company < Filings
  # field :metadata, :string, default: -> { "company-#{SecureRandom.uuid}" }
  field :name
  field :cusip
  field :tradingSymbol
  field :formerNames, JsonArray
  field :assistantDirector
  field :sicCode
  field :sicIndustryTitle
  field :sicListHref
  field :stateOfIncorporation
  field :stateLocation
  field :stateLocationHref
  field :cikHref
  field :businessAddress, :raw
  field :mailingAddress, :raw

  class << self
    alias_method :old_find, :find

    def find(cik, metadata)
      old_find(cik, range_key: metadata)
    end

    def merge_or_create(data)
      # company = find(cik: data[:cik]) || new(data)
      company = new(data)
      [company.persisted? ? company.update_attributes(data) : company.save, company]
    end
  end
end

class HedgeFund < Filings
  field :metadata, :string, default: -> { "hedge-fund" }
  field :name
  field :mailingAddress, :raw
  field :businessAddress, :raw
  field :assignedSic
  field :assignedSicDesc
  field :assignedSicHref
  field :assistantDirector
  field :cikHref
  field :formerNames, JsonArray
  field :stateLocation
  field :stateLocationHref
  field :stateOfIncorporation
end

class TrackedFiling < Filings
  field :metadata, :string, default: -> { "tracked-filing-#{SecureRandom.uuid}" }
  field :fund_name
  field :type

  validates_presence_of :type
  validates_presence_of :fund_name
end
