require 'dynamoid'
Dynamoid.configure do |config|
  # To namespace tables created by Dynamoid from other tables you might have.
  # Set to nil to avoid namespacing.
  config.namespace = nil

  # [Optional]. If provided, it communicates with the DB listening at the endpoint.
  # This is useful for testing with [DynamoDB Local] (http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html).

  if ENV['LAMBDA_ENV'] == 'production'
    # Use DynamoDB
  elsif ENV['LAMBDA_ENV'] == 'test'
    config.endpoint = 'http://localhost:8000'
  else
    # sam local api
    config.endpoint = 'http://host.docker.internal:8000'
  end
end

module Dynamoid::Document
  module ClassMethods
    def choose_right_class(attrs)
      return self unless attrs[inheritance_field]

      if attrs[inheritance_field].include?('-')
        klass_name = attrs[inheritance_field].gsub(/-[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/, '').split('-').map{|str| str.capitalize}.join
      else
        klass_name = attrs[inheritance_field]
      end

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
    chain.all.to_a
  end
end

class Company < Filings
  def self.name
    'Company'
  end

  field :metadata, :string, default: -> { 'Company' }
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

    def find(cik)
      old_find(cik, range_key: 'Company')
    end

    def find_by_ticker(ticker)
      where(tradingSymbol: ticker)&.all&.first
    end

    def merge_or_create(data)
      company = find(cik: data[:cik]) || new(data)
      [company.persisted? ? company.update_attributes(data) : company.save, company]
    end
  end
end

class HedgeFund < Filings
  field :metadata, :string, default: -> { name }
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

  class << self
    alias_method :old_find, :find

    def find(cik)
      old_find(cik, range_key: 'HedgeFund')
    end
  end
end

# module Dynamoid
#   module Criteria
#     # The criteria chain is equivalent to an ActiveRecord relation (and realistically I should change the name from
#     # chain to relation). It is a chainable object that builds up a query and eventually executes it by a Query or Scan.
#     class Chain
#       def initialize(source)
#         @query = {}
#         @source = source
#         @consistent_read = false
#         @scan_index_forward = true
#
#         # Honor STI and :type field if it presents
#         type = @source.inheritance_field
#         if @source.attributes.key?(type)
#           @query[:"#{type}.in"] = @source.deep_subclasses.map(&:name) << @source.name
#         end
#
#         # we should re-initialize keys detector every time we change query
#         @key_fields_detector = KeyFieldsDetector.new(@query, @source)
#       end
#     end
#   end
# end

class TrackedFiling < Filings
  include Dynamoid::Document

  field :metadata, :string, default: -> { "tracked-filing-#{SecureRandom.uuid}" }
  field :fundName
  field :type, :string, default: 'TrackedFiling'
  field :reported, :boolean

  def self.name
    'TrackedFiling'
  end

  validates_presence_of :type
  validates_presence_of :fundName

  def self.where(*args)
    chain = super(*args)
    chain.query.reject! {|k, _v| k == :"metadata.in"}.merge!(:"metadata.begins_with" => "tracked-filing-")
    chain
  end

  def self.find_by_cik(cik)
    where(cik: cik).all.to_a
  end

  def self.all
    where({})
  end

  def self.all_reported
    all.to_a.select {|f| f.reported }
  end

  def self.partitioned_reported
    found = all_reported
    return found unless found.any?
    filing_types = %w[4 13F-HR]
    filing_types.each_with_object({}) do |filing_type, partitioned|
      type_filings, found = found.partition {|f| f.type == filing_type }
      partitioned[filing_type] = type_filings
    end
  end
end

# Filing entries of the SEC RSS Feed
class ReportedFiling < Filings
  field :metadata, :string, default: -> { "reported-filing-#{SecureRandom.uuid}" }
  field :type, :string, default: 'ReportedFiling'

  field :reportingCik
  field :issuerCik
  field :title
  field :term
  field :summary
  field :label
  field :filingDetailUrl
  field :secAccessionNumber
  field :dateFiled

  validates_presence_of :term

  class << self
    alias_method :old_find, :find

    def find(cik, term, secAccessionNumber)
      old_find(cik, range_key: "#{term}-#{secAccessionNumber}")
    end

    def where(*args)
      chain = super(*args)
      chain.query.reject! {|k, _v| k == :"metadata.in"}.merge!(:"metadata.begins_with" => "reported-filing-")
      chain
    end

    def find_by_cik(cik)
      where(cik: cik).all.to_a
    end

    def all
      where({})
    end

    def merge_or_create(data)
      company = find(data[:cik], data[:term], data[:secAccessionNumber]) || new(data)
      [company.persisted? ? company.update_attributes(data) : company.save, company]
    end
  end
end