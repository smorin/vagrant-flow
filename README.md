# Vagrant-Flow

Vagrant Plugin allows for a better ansible flow. It generates ansible inventory files to easily prepare to run ansible playbooks


## Installation

`vagrant plugin install vagrant-flow`


Below is how to install as a regular gem which won't work

Add this line to your application's Gemfile:

    gem 'vagrant-flow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vagrant-flow

* * *

# Usage
## ansibleinventory
```
Usage: vagrant flow ansibleinventory [-hgpq]
This plugin looks for groupconfig.yml as the default configuration
Do not use -p and -g options together!

    -g, --group_config_file FILEPATH (Optional) YAML file containing group config
    -p, --vagrantfileparse           (Optional) Read in the VAGRANTFILE's ansible group config
    -q, --quiet                      (Optional) Suppress output to STDOUT and STDERR
    -h, --help                       (Optional) Print this help
```

#### Example usages of ansibleinventory
This will look for a file in the pwd named groupconfig.yml and attempt to make the inventory
```
vagrant flow ansibleinventory
```



This will look for a file in the pwd named myOwnGroupConfig.yml and attempt to make the inventory
```
vagrant flow ansibleinventory -g myOwnGroupConfig.yml
```



This will parse the vagrant file for ansible group configs
```
vagrant flow ansibleinventory -p
```





### Use case
```
#Bring up your vagrant machines
vagrant up
#Run ansible inventory (this assumes the file groupconfig.yml exists)
vagrant ansible-inventory
#point ansible-playbook to the generated vagrant-flow_ansible_inventory, and point them to whatever playbook you'd like
ansible-playbook -i path/to/vagrant-flow_ansible_inventory my_playbook.yml
```

Example groupconfig.yml file (for use with no optional command line arguments or  by pointing to non-default file with -g option)
```
---
common:children:
- testgroup
- servergroup
testgroup:
- testbox
servergroup:
- server1
- server2
```

Example VAGRANTFILE excerpt (for use with -p option):
```
config.vm.provision "ansible" do |ansible|
    #ansible.playbook is required, but emptyplaybook.yml can do nothing, 
    #this way we bypass vagrant's embedded ansible plugin
    ansible.playbook="emptyplaybook.yml"
    ansible.groups = {
      "testgroup" => ["testbox"],
      "servergroup" => ["server1", "server2"],
      "common:children" => ["testgroup","servergroup"] #Common things on per-group basis
    }
  end
```

Example playbook.yml to use after ansible-inventory has run with command `ansible-playbook -i vagrant-flow_ansible_inventory playbook.yml`:
```
---
  #Configures the groups defined in common:children
- hosts: common
  remote_user: root
  roles:
    - common

  #Configures all machines in the group "testgroup"
- hosts: testgroup
  remote_user: root
  roles:
    - jenkins
 
  #Configures specific machine server1
- hosts: server1
  roles:
    - apache
```
* * *
## multiinit
```
Usage: vagrant flow multiinit [-hgliq]
This looks for multiinit.yml as the default configuration

    -g FILEPATH,                     (Optional) YAML file containing vagrant cloud config
        --vagrant_multiinit_config_file
    -l hostname:cloud/location,hostname2:cloud/location2,hostname3:cloud/location3,
        --list                       List of cloud config parameters
    -i, --vboxintnet NAME            (Optional) Custom virtualbox__intnet name for private network
    -q, --quiet                      (Optional) Suppress output to STDOUT and STDERR
    -h, --help                       Print this help
```

#### Example usages of multiinit
This will look for a file in the pwd named multiinit.yml and attempt to make the Vagrantfile
```
vagrant flow multiinit
```



This will look for a file in the pwd named myOwnGroupConfig.yml and attempt to make the inventory
```
vagrant flow multiinit -g myOwnMultiInitConfig.yml
```



This will read in from the command line a list of [vm_name]:[url] combinations.  It MUST follow the following format.  The -i option will also set the virtualbox__intnet name to a custom option ("virtualboxprivatenet" in this case)
```
vagrant flow multiinit -l boxname1:demandcube/centos-65_x86_64-VB-4.3.8,boxname2:demandcube/centos-65_x86_65-VB-4.3.8,box3:provider/boxname -i virtualboxprivatenet
```


### Use case
```
#Create your multi-box Vagrantfile
vagrant flow multiinit
#Launch the boxes
vagrant up
```

Example multiinitconfig.yml file (for use with no optional command line arguments or by pointing to non-default file with -g option).  The format of this yaml file MUST be followed, but can easily be expanded to include more of fewer machines
```
---
:intnetName: neverwinterDP
machines:
- name: machine1
  url: demandcube/centos-65_x86_64-VB-4.3.8
- name: server1
  url: demandcube/centos-64_x86_64-VB-4.3.8
- name: jenkinstestmachine
  url: demandcube/centos-65_x86_64-VB-4.3.8

```


* * *

## Contributing

1. Fork it ( http://github.com/DemandCube/vagrant-flow/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Development Flow

```
# cd to vagrant-flow

# build the plugin

rake build

# install the plugin locally

vagrant plugin install pkg/vagrant-flow-1.0.3.gem

#
# use it and test
#

vagrant plugin uninstall vagrant-flow


#
# when done testing and ready to publish
#

rake release


# install for real from the repo

vagrant plugin install vagrant-flow
```

# Background Research

Vagrant Plugin List
=====
* <https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins>

Creating a Gem
=====
* Tutorial <>
* <http://railscasts.com/episodes/245-new-gem-with-bundler>

Commands 

```

bundle gem lorem           # will generate a directory 'lorem' with stubs for a gem
gem build lorem.gemspec    # Build the ruby gem
gem push lorem-0.0.1.gem   # Push the gem to rubygems.org
bundle                     # Uses Gemfile to download and install necessary dependencies
rake -T                    # Shows tasks in the Rakefile, some added by bundler 
                           #   with Bundler::GemHelper.install_tasks
rake build                 # It's a helper that will build your gem
rake install               # It's a helper that will build and install locally
rake release               # It's a helper that will push/release to rubygems

```
