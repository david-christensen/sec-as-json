require_relative 'seed_company'

def handler(event:, context:)
  SeedCompany.handle_event(event: event, context: context)
end
