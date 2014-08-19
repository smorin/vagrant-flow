# Vagrant-Flow

Vagrant-Flow enables a seamless development to production workflow.

Vagrant-Flow is a [vagrant] (http://www.vagrantup.com/) plugin which allows for a separation of ansible playbooks from vagrant, mimicing how development works. It enables the generates ansible inventory files, vagrant templates and inter-machine communication to easily prepare to run ansible playbooks and machine communication.

- This is part of [NeverwinterDP the Data Pipeline for Hadoop](https://github.com/DemandCube/NeverwinterDP)


## Installation

```
#This is so 'vagrant flow hostfile' can automatically connect to digital ocean machines
#Otherwise it will hang when dealing with remote hosts
echo "StrictHostKeyChecking no" >> ~/.ssh/config

#If you're on OSX
#This step may no longer be necessary as vagrant-digitalocean shouldn't require it anymore
brew install curl-ca-bundle


vagrant plugin install vagrant-digitalocean
vagrant plugin install vagrant-flow
```

## Contributing

See the [NeverwinterDP Guide to Contributing] (https://github.com/DemandCube/NeverwinterDP#how-to-contribute)


* * *

## Usage and Specs
vagrant-flow has 1 command `flow` and the following subcommands:

```
multiinit
hostfile
ansibleinventory
playbook
```

- multiinit
  - Creates a template Vagrantfile based on the machines you specify
- hostfile
  - Creates a hostfile and copies it to each VM so that machine can talk to each other
- ansibleinventory
  - Create a ansible machine inventory file so that you can use ansible to provision the machines
- playbook
  - Uses a confile to run ansible-play book to provision one or more VM's

Example flow to be enabled
```
vagrant plugin install vagrant-flow
git clone http://github.com/DemandCube/DeveloperPlaybooks
mkdir devsetup
cd devsetup
vagrant flow multiinit -l boxname1:demandcube/centos-65_x86_64-VB-4.3.8,boxname2:demandcube/centos-65_x86_65-VB-4.3.8
vagrant up
vagrant flow hostfile
vagrant flow ansibleinventory

# Then

vagrant flow playbook
# or
ansible-playbook -i ansible-flow_inventoryfile ../DeveloperPlaybooks/site.yml

#communication test
vagrant ssh boxname1 ping boxname2
vagrant ssh boxname2 ping boxname1
```

#DemandCube Boxes
Publically available boxes in vagrantcloud from DemandCube:
- vagrant init demandcube/centos-64_x86_64-VB-4.3.8
- vagrant init demandcube/centos-65_x86_64-VB-4.3.8



# Usage


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
#Or launch with digitalocean
vagrant up --provider=digital_ocean
```

Example multiinitconfig.yml file (for use with no optional command line arguments or by pointing to non-default file with -g option).  The format and parameters of this yaml file MUST be followed, but can easily be expanded to include more of fewer machines
```
---
:intnetName: neverwinterDP
machines:
  #This will use all defaults and create a guest named machine1
- name: machine1
  #Create another machine, but specify which .box to use with virtual box
- name: server1
  url: demandcube/centos-64_x86_64-VB-4.3.8
- name: jenkinstestmachine
  url: demandcube/centos-65_x86_64-VB-4.3.8

```

Example multiinitconfig.yml file for use with virtualbox and digitalocean providers.  All the extra parameters are required to make digitalocean work.  Get your digitalOcean token by logging in and generating a new token under "Apps & API"
```
---
#Where your ssh private key lives (for use with digital ocean)
#~/.ssh/id_rsa is the default, so you can omit this value if you want
:sshPrivateKeyPath: ~/.ssh/id_rsa


#The digitalOceanToken must be set for digitalocean to work.  You can generate one at https://cloud.digitalocean.com/settings/applications
#Omit it if you don't want digitalocean as a provider option in your vagrantfile
:digitalOceanToken: xxxxxxxxxxxxxxyyyyyyyzzzzz988765445678765


:intnetName: neverwinterDP
machines:
  #Create a box with all defaults set for you
- name: fulldefaults

  #Use a custom url for your virtual box image
- name: customvboxurl
  url: demandcube/centos-64_x86_64-VB-4.3.8

  #Set custom config for digitalocean
- name: digitaloceancustom
  digitalOceanRegion: nyc2
  digitalOceanImage: Debian 7.0 x64
#Valid options for digitalOceanRegion:
#"nyc1, ams1, sfo1, nyc2, ams2, sgp1, lon1
#Default is sfo1

  #Set custom config for vbox and digitaloceanprovider
- name: digitaloceanvboxcustom
  url: demandcube/centos-64_x86_64-VB-4.3.8
  digitalOceanRegion: sgp1
  digitalOceanImage: Debian 7.0 x64

  #Set custom config for vbox and digitaloceanprovider and sets amount of RAM
- name: digitaloceanvboxcustom
  url: demandcube/centos-64_x86_64-VB-4.3.8
  digitalOceanRegion: sfo1
  digitalOceanImage: Debian 7.0 x64
  ram: 2GB
  #Valid options for RAM (This is a digital ocean restriction):
  #    512MB, 1GB, 2GB, 4GB, 8GB, 16GB, 32GB, 48GB, 64GB
  #Default RAM is 512MB

```

* * *
##hostfile
Usage: vagrant flow hostfile [-qndoh]
Edits all your VMs /etc/hosts file to be able to find all the machines on your private network

    -q, --quiet                      (Optional) Suppress output to STDOUT and STDERR
    -n, --no-write-hosts             (Optional) Don't actually write a new hosts file to the guest machine
    -d, --digitalocean               (Optional) Writes your digital ocean's hostnames and IP addresses to hosts file.  Default file is hostfile_do.yml
    -o, --digitaloceanfile FILE      (Optional) File to read in for -d option instead of hostfile_do.yml
    -h, --help                       Print this help

#### Example usages of hostfile
This will look through your vagrantfile config, find all the hostnames and IP's configured in your private_network, and append that information to all your machine's /etc/hosts file
```
vagrant flow hostfile
```

This will make an API call to digital ocean (https://developers.digitalocean.com/droplets/), retrieve your list of hostnames and Ip's, and append that information retrieved from DO to the VM's hosts file specified in your Vagrantfile. The config file it will look for by default is the same as the file for multiinit - multiinitconfig.yml
```
vagrant flow hostfile -d
```

Example Vagrantfile excerpt.  This configuration is required by hostfile to be able to determine IP addresses and hostnames.
If you're already using vagrant flow multiinit, then this configuration is already take care of
```
  config.vm.define :server1 do | server1 |
    server1.vm.box = "demandcube/centos-65_x86_64-VB-4.3.8"
    # Create a private network
    server1.vm.network :private_network, ip: "192.168.1.2", virtualbox__intnet: "neverwinterDP"
    server1.vm.hostname = "server1"
  end

  config.vm.define :server2 do | server2 |
    server2.vm.box = "demandcube/centos-65_x86_64-VB-4.3.8"
    # Create a private network
    server2.vm.network :private_network, ip: "192.168.1.3", virtualbox__intnet: "neverwinterDP"
    server2.vm.hostname = "server2"
  end
```

Refer to multiinit for how to set your digital ocean token
To find your digital ocean token, log into digital ocean, and visit https://cloud.digitalocean.com/api_access

* * *
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
vagrant flow ansibleinventory
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

Example output (file will be called vagrant-flow_ansible_inventory)
```
# Generated by vagrant-flow, part of NeverwinterDP

[testgroup]
jenkins ansible_ssh_host=127.0.0.1 ansible_ssh_port=2201 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/Users/rcduar/.vagrant.d/insecure_private_key # Machine Name: jenkins

[servergroup]
server1 ansible_ssh_host=127.0.0.1 ansible_ssh_port=2222 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/Users/user/.vagrant.d/insecure_private_key # Machine Name: server1

[common:children]
testgroup
servergroup
```

* * *
##playbook
```
Usage: vagrant flow playbook [-hpf]
Reads in config from flow-playbook.yml by default to be able to run ansible-playbook more easily

    -f, --file-playbook FILE         (Optional) Use a specified playbook config file instead of default (flow-playbook.yml)
    -p, --print-only                 (Optional) Don't actually ansible-playbook, but just output what would be run to STDOUT
    -q, --quiet                      (Optional) Suppress output to STDOUT and STDERR
    -h, --help                       Print this help
```

This will run ansible-playbook based on the config in flow-playbook.yml
```
vagrant flow playbook
```

This will run ansible-playbook based on the config in myOwnConfig.yml
```
vagrant flow playbook -f myOwnConfig.yml
```

This will not actually run ansible-playbook, but will only output the command it would run to STDOUT
```
vagrant flow playbook -p
```
The output from the above command using -p will look like this:
```
ansible-playbook -i vagrant-flow_ansible_inventory myPlaybooks/main.yml
```

###Expectations:
Example flow-playbook.yml file
```
---
:playbook: defaultplaybook.yml             #Required
:inventory: vagrant-flow_ansible_inventory #Required
:pattern: '*'                              #Optional.  Will be used in conjunction like so 'ansible-playbook -l [pattern] -i [inventory] -p [playbook]'
```

* * *

## Future Usage and Specs
Looking for vagrant-flow to have the following commands:

```
init-flow
ansible-inventory
hostfile-local
hostfile-remote
flow
```
- init-flow -> creates a stub Vagrant file but takes more options
- ansible-inventory -> creates a ansible-inventory file from the virtualmachines that are there
- hostfile-local -> create a hostfile that can be appended to your /etc/hosts locally so you can reference the vm's
- hostfile-remote -> updates the /etc/hosts on all the vm's created by vagrant so they can talk to each other
- flow -> calls ansible-inventory and hostfile-remote in 1 command.

Example flow to be enabled
```
vagrant plugin install vagrant-flow
git clone http://github.com/DemandCube/DeveloperPlaybooks
mkdir devsetup
cd devsetup
vagrant init-flow frontend1 frontend2:ubuntu-12
vagrant flow
ansible-playbook -i ansible-flow_inventoryfile ../DeveloperPlaybooks/site.yml

#communication test
vagrant ssh frontend1 ping frontend2
vagrant ssh frontend2 ping frontend1
```




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

Below is how to install as a regular gem which won't work

Add this line to your application's Gemfile:

    gem 'vagrant-flow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vagrant-flow

* * *

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
!!!!
