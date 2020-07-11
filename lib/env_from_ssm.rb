require 'aws-sdk-ssm'

ssm = Aws::SSM::Client.new
params = ssm.get_parameters(
  names: [
    "/sec_on_jets/dev/SEC_ON_JETS_API_KEY",
    "/sec_on_jets/dev/SEC_ON_JETS_URL"
  ], # required
  with_decryption: true
)&.parameters

params.each do |param|
  env_var_name = param['name'].split('/').last
  puts "Setting ENV['#{env_var_name}']"
  ENV[env_var_name] = param['value']
end

puts "ENV['SEC_ON_JETS_URL'] ::: #{ENV['SEC_ON_JETS_URL']}"
