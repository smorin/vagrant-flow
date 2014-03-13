require 'yaml'



###This shows how to make a valid configuration file in YAML format for vagrant-flow to consume with the ansible-inventory command

x = {
 "common:children"=>["jenkins","server"],
 "jenkins"=>["jenkinsdp"],
 "server"=>["sparkngin1","sparkngin2"],
}

begin
  File.open('groupconfig.yml', 'w') {|f| f.write x.to_yaml }
rescue
  warn "Could not write file groupconfig.yml"
end

y = YAML.load(x.to_yaml)

y.each {|key,value|
  puts key
  puts value
  puts "\n"
}

