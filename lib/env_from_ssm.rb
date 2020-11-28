require 'aws-sdk-ssm'

ssm = Aws::SSM::Client.new
params = ssm.get_parameters(
  names: [
    "/sec-as-json/dev/REPORTED_FILINGS_TOPIC",
    "/sec_graph/dev/SEC_GRAPH_API_KEY",
    "/sec_graph/dev/SEC_GRAPH_URL"
  ], # required
  with_decryption: true
)&.parameters

params.each do |param|
  env_var_name = param['name'].split('/').last
  puts "Setting ENV['#{env_var_name}']"
  ENV[env_var_name] = param['value']
end

puts "ENV['SEC_GRAPH_URL'] ::: #{ENV['SEC_GRAPH_URL']}"
