require 'yaml'



###This shows how to make a valid configuration file in YAML format for vagrant-flow to consume with the ansible-inventory command

x = {
  :api_key => "apikeygoeshere",
  :client_id => "clientidgoeshere",
}

begin
  File.open('hostfile_do.yml', 'w') {|f| f.write x.to_yaml }
rescue
  warn "Could not write file hostfile_do.yml"
end

y = YAML.load(x.to_yaml)

y.each {|key,value|
  puts key
  puts value
  puts "\n"
}

