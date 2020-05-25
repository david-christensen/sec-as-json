require_relative 'seed_company'

def seed_company_handler(event:, context:)
  SeedCompany.handler(event: event, context: context)
end
