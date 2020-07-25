require 'json'
require 'yaml'

template = YAML.load_file('template.yaml')
table_templates = template['Resources'].values.select{|r| r['Type'] == "AWS::DynamoDB::Table"}.map{|r| r['Properties'] }

table_templates.each do |template_content|
  puts "Creating #{template_content["TableName"]} table"
  File.open("#{template_content["TableName"]}.json","w") do |f|
    f.write(JSON.pretty_generate(template_content))
  end
  `aws dynamodb create-table --cli-input-json file://#{template_content["TableName"]}.json --endpoint-url http://localhost:8000 --region x`
  File.delete("#{template_content["TableName"]}.json")
end