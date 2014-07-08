require 'yaml'



###This shows how to make a valid configuration file in YAML format for vagrant-flow to consume with the ansible-inventory command
x = {
  #~/.ssh/id_rsa is also the default
  :sshPrivateKeyPath =>"~/.ssh/id_rsa",
  
  #These two keys must be set for digitalocean to work
  #Omit them if you don't want digitalocean as a provider option in your vagrantfile
  :digitalOceanApiKey => "123456789098765432",
  :digitalOceanClientId => "fytudisughfsdalk",
  
  :intnetName=>"neverwinterDP",
  "machines" => [
   {"name"=>"fulldefaults"},
   {"name"=>"customvboxurl", "url"=>"demandcube/centos-64_x86_64-VB-4.3.8",},
   {"name"=> "digitaloceancustom", "digitalOceanRegion" => "New York 2", "digitalOceanImage"=>"Debian 7.0 x64"},
   {"name"=> "digitaloceanvboxcustom", "url"=>"demandcube/centos-64_x86_64-VB-4.3.8", "digitalOceanRegion" => "New York 2", "digitalOceanImage"=>"Debian 7.0 x64" },
   {"name"=> "digitaloceanvboxcustomwithRam", "url"=>"demandcube/centos-64_x86_64-VB-4.3.8", "digitalOceanRegion" => "New York 2", "digitalOceanImage"=>"Debian 7.0 x64", "ram"=>"2GB" },
  ]
}

begin
  File.open('multiinitconfig.yml', 'w') {|f|
    f.write x.to_yaml
  }
rescue
  warn "Could not write file multiinit.yml"
end


y = YAML.load(x.to_yaml)

y.each {|key,value|
  puts key
  puts value
  puts "\n"
}
