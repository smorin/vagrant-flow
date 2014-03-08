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

## Usage
```
#Bring up your vagrant machines
vagrant up
#Run ansible inventory
vagrant ansible-inventory
#point ansible-playbook to the generated vagrant-flow_ansible_inventory, and point them to whatever playbook you'd like
ansible-playbook -i path/to/vagrant-flow_ansible_inventory my_playbook.yml
```
## Usage Expectations

This plugin expects your vagrantfile to contain a configuration to define groups for all your VMs.  

Example VAGRANTFILE excerpt:
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

Example playbook.yml:
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

vagrant plugin vagrant-flow
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
