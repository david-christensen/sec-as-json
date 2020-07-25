aws dynamodb delete-table --table=filings --endpoint-url http://localhost:8000 --region x
ruby dbcreate.rb
ruby seed_hedge_funds.rb
