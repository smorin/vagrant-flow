require 'yaml'



###This shows how to make a valid configuration file in YAML format for vagrant-flow to consume with the ansible-inventory command
x = {
  :playbook => "defaultplaybook.yml",
  :inventory => "vagrant-flow_ansible_inventory",
  #:pattern => "*",  #:pattern is optional
}

begin
  File.open('flow-playbook.yml', 'w') {|f|
    f.write x.to_yaml
  }
rescue
  warn "Could not write file flow-playbook.yml"
end


y = YAML.load(x.to_yaml)

y.each {|key,value|
  puts key
  puts value
  puts "\n"
}
