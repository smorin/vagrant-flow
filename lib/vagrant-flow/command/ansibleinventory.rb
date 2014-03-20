require 'optparse'
require "vagrant"
require "yaml"

module VagrantPlugins
  module AnsibleInventory
    class Command < Vagrant.plugin("2", :command)
      
      # Builtin from Command class
      # Must override to provide a description
      def self.synopsis
        "generates a ansible inventory file from the vagrant environment"
      end

      
      # Builtin from Command class
      # Must override to provide core functionality
      def execute
        
        machines_configs = {}
        inventory_configs = {}
        
        default_group_config_file = "groupconfig.yml"
        options = {}
        options[:destroy_on_error] = true
        options[:parallel] = false
        options[:provision_ignore_sentinel] = false
        options[:quiet] = false
        
        #Setting to read in a file other than default_group_config_File
        options[:custom_config_file] = false
        #Setting to parse the VAGRANTFILE's ansible group config
        options[:vagrantFileAnsibleConfig] = false
        
        #Parse option, look up OptionParser documentation 
        opts = OptionParser.new do |o|
          # o.banner = "Usage: vagrant ansible-inventory [vm-name] [options] [-h]"
          o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                      "Usage: vagrant ansible-inventory [-hgpq]\nThis looks for groupconfig.yml as the default configuration\n"+
                      "Do not use -p and -g options together!"
          o.separator ""
          o.on("-g", "--group_config_file FILEPATH", "(Optional) YAML file containing group config") do |f|
            options[:custom_config_file] = f        
          end
          
          o.on("-p", "--vagrantfileparse", "(Optional) Read in the VAGRANTFILE's ansible group config") do |f|
            options[:vagrantFileAnsibleConfig] = true
          end
          
          o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
            options[:quiet] = true
          end
          
        end

        # Parse the options # Builtin from the Command Class
        # Will safely parse the arguments and 
        # Automatically detects -h for help
        argv = parse_options(opts)
        return if !argv
        
        

        # The following are already setup by the parent class
        # @env
        # @logger
        # @argv

        # Go over each VM and bring it up
        @logger.debug("'ansible-inventory' created for the whole env")
        
        #Initialize group_machines, the has containing group=>machinename configs
        group_machines={}
        
        #Get info about the vagrant boxes
        with_target_vms(argv, :provider => options[:provider]) do |machine|
          # @env.ui
          # output methods: :ask, :detail, :warn, :error, :info, :output, :success
          # https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/ui.rb
          
          ssh_info = machine.ssh_info
          raise Vagrant::Errors::SSHNotReady if ssh_info.nil?

          variables = {
            :host_key => options[:host] || machine.name || "vagrant",
            :ssh_host => ssh_info[:host],
            :ssh_port => ssh_info[:port],
            :ssh_user => ssh_info[:username],
            :private_key_path => ssh_info[:private_key_path],
            :forward_agent => ssh_info[:forward_agent],
            :forward_x11   => ssh_info[:forward_x11]
          }
          # Outputs to the stdout
          
          inventory_configs = {
            :vagrant_file_dir => machine.env.root_path,
            :vagrant_flow_file => machine.env.root_path.join("vagrant-flow_ansible_inventory")
          }
          
          machines_configs[variables[:host_key]]= variables
        end
        
        #Hash containing group/machine configuration
        group_machines={}
        #Determine group_machines based on what config options are passed in
        #Read in config from vagrantfile's ansible config
        if options[:vagrantFileAnsibleConfig] == true
          provisioners = []
          with_target_vms(argv, :provider => options[:provider]) do |machine|
            #The provisioning information from teh vagrant file, this will contain our defined ansible groups
            #Concatenate all the provisioner configs together
            if machine.config.vm.provisioners
              provisioners.concat(machine.config.vm.provisioners)
            end
          end
          #Since Vagrant machines will likely contain the same configs,
          #Merge the config together to remove duplicate entries in our
          #group/machine configuration
          provisioners.each {|prov|
            group_machines = group_machines.merge(prov.config.groups)
          }
        #Read in config from yaml file
        else
          #Use config option if specified
          if options[:custom_config_file] != false
              default_group_config_file = options[:custom_config_file]
          end
          begin
            #Load YAML
            group_machines = YAML.load_file(default_group_config_file)
          rescue
            #Give warning if no file could be found
            if not options[:quiet]
              warn "Could not open file: "+default_group_config_file.to_s
            end
          end
        end
        
        
        
        # Outputs to the stdout
        # @env.ui.info(machine.name)
        
        # From - Vagrant::Util::SafePuts
        # Template is erb
        
        # Implementation picks the first key
        # ssh_info[:private_key_path] returns an array
 
        #outputs is going to contain our strings that are the formatted ansible configs
        #the key will be the vm name, the value will the be formatted sring
        outputs = {}
        
        inventory_configs[:vagrant_flow_file].open('w') do |file|
          machines_configs.each do |host, variables|
            ansible_template = '<%= host_key %> ansible_ssh_host=<%= ssh_host %> ansible_ssh_port=<%= ssh_port %> ansible_ssh_user=<%= ssh_user %> ansible_ssh_private_key_file=<%= private_key_path[0] %> # Machine Name: <%= host_key %>'
            outputs[variables[:host_key]] = Vagrant::Util::TemplateRenderer.render_string(ansible_template, variables)
            #safe_puts(host_txt)
            #file.write("#{host_txt}\n")
          end
        end
        
        #require 'pp'
        #puts "PROVISIONERS"
        #PP.pp(provisioners)
        #puts "OUTPUTS"
        #PP.pp(outputs)
        #puts "\n\n"
        
        
        
        inventory_configs[:vagrant_flow_file].open('w') do |file|
          header_txt="# Generated by vagrant-flow, part of NeverwinterDP\n\n"
          if not options[:quiet]
            safe_puts(header_txt)
          end
          file.write(header_txt)
          
          #Now we maps from our VAGRANTFILE defined groups in our provisioners.config.groups
          #To our configuration strings we got from outputs
          group_machines.each do |groupname,machines|
            if not options[:quiet]
              puts "["+groupname+"]\n"
            end
            file.write "["+groupname+"]\n"
            machines.each do |machinename|
              #if we match :children, then we have an ansible config that's
              #pointing to another group, not a specific machine
              if /:children/.match(groupname)
                if not options[:quiet]
                  puts machinename
                end
                file.write machinename+"\n"
              else
                if not options[:quiet]
                  puts outputs[machinename.to_sym]+"\n"
                end
                file.write outputs[machinename.to_sym]+"\n"
              end
            end
            if not options[:quiet]
              puts "\n"
            end
            file.write "\n"
          end    
        end          
        0
      end # End Execute
      
      
      # Documentation reference
      # http://docs.ansible.com/intro_inventory.html
      
      def setup_inventory_file(machine)
        return machine.config.inventory_path if machine.config.inventory_path

        ssh = machine.ssh_info

        generated_inventory_file =
          machine.env.root_path.join("vagrant-flow_ansible_inventory")

        generated_inventory_file.open('w') do |file|
          file.write("# Generated by Vagrant\n\n")
          file.write("#{machine.name} ansible_ssh_host=#{ssh[:host]} ansible_ssh_port=#{ssh[:port]}\n")

          # Write out groups information.  Only include current
          # machine and its groups to avoid Ansible errors on
          # provisioning.
          groups_of_groups = {}
          included_groups = []

          config.groups.each_pair do |gname, gmembers|
            if gname.end_with?(":children")
              groups_of_groups[gname] = gmembers
            elsif gmembers.include?("#{machine.name}")
              included_groups << gname
              file.write("\n[#{gname}]\n")
              file.write("#{machine.name}\n")
            end
          end

          groups_of_groups.each_pair do |gname, gmembers|
            unless (included_groups & gmembers).empty?
              file.write("\n[#{gname}]\n")
              gmembers.each do |gm|
                file.write("#{gm}\n") if included_groups.include?(gm)
              end
            end
          end
        end

        return generated_inventory_file.to_s
      end
      
    end
  end
end
