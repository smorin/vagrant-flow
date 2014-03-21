require "vagrant"
require 'optparse'
require "yaml"
require 'erubis'

module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class CloudBox < Vagrant.plugin("2", :command)
        
        # Builtin from Command class
        # Must override to provide a description
        def self.synopsis
          "Grabs a multitude of vagrant cloud boxes"
        end
        
        
        # Builtin from Command class
        # Must override to provide core functionality
        def execute
          default_group_config_file = "vagrantcloudconfig.yml"
          options = {}
          options[:destroy_on_error] = true
          options[:parallel] = false
          options[:provision_ignore_sentinel] = false
          options[:quiet] = false
          
          #Default virtualbox__intnet name for private network
          options[:vboxintnet] = "neverwinterDP"
          
          #Setting to read in a file other than default_group_config_File
          options[:vagrant_cloud_config_file] = false
          
          #Parse option, look up OptionParser documentation 
          opts = OptionParser.new do |o|
            # o.banner = "Usage: vagrant ansible-inventory [vm-name] [options] [-h]"
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow cloudbox [-hgpq]\nThis looks for groupconfig.yml as the default configuration\n"
            o.separator ""
            o.on("-g", "--vagrant_cloud_config_file FILEPATH", "(Optional) YAML file containing vagrant cloud config") do |f|
              options[:vagrant_cloud_config_file] = f        
            end
            
            o.on( '-l', '--list hostname:cloud/location,hostname2:cloud/location2,hostname3:cloud/location3', Array, "List of cloud config parameters" ) do|f|
              options[:vagrant_cloud_list] = f
            end
            
            o.on("-i", "--vboxintnet", "(Optional) Custom virtualbox__intnet name for private network") do |f|
              options[:vboxintnet] = f
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
          
          
          #If no options are given, set the config file to the default
          #and continue on our merry way
          if not options[:vagrant_cloud_config_file] and not options[:vagrant_cloud_list]
            options[:vagrant_cloud_config_file] = default_group_config_file
          end
          
          #Get machine configs from config file or from command line
          content = {}
          if options[:vagrant_cloud_config_file]
            begin
              #Load YAML
              content = YAML.load_file(options[:vagrant_cloud_config_file])
            rescue
              #Give warning if no file could be found
              if not options[:quiet]
                warn "Could not open file: "+options[:vagrant_cloud_config_file].to_s
              end
            end
          end
          
          #Read in command line config
          if options[:vagrant_cloud_list]
            machines = []
            options[:vagrant_cloud_list].each {|item|
              split = item.split(":")
              machines.push({
                              "name"=>split[0],
                              "url"=>split[1],
                              })
            }
            content = {
              "intnetName"=>options[:vboxintnet],
              "machines" => machines,
            }
          end
          
          #Put Vagrantfile in pwd
          save_path = Pathname.new("Vagrantfile").expand_path(@env.cwd)
          puts save_path
          raise Vagrant::Errors::VagrantfileExistsError if save_path.exist?
          
          template_path = File.join(File.expand_path("..",File.dirname(__FILE__)) , ("templates/cloudbox.erb"))
          puts template_path
          eruby = Erubis::Eruby.new(File.read(template_path))
          
          
          begin
            save_path.open("w+") do |f|
              f.write(eruby.evaluate(content))
            end
          rescue Errno::EACCES
            raise Vagrant::Errors::VagrantfileWriteError
          end
        
          
          
=begin
require 'optparse'

require 'vagrant/util/template_renderer'

module VagrantPlugins
  module CommandInit
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "initializes a new Vagrant environment by creating a Vagrantfile"
      end

      def execute
        options = { output: "Vagrantfile" }

        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant init [name] [url]"
          o.separator ""
          o.separator "Options:"
          o.separator ""

          o.on("--output FILE", String,
               "Output path for the box. '-' for stdout") do |output|
            options[:output] = output
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        save_path = nil
        if options[:output] != "-"
          save_path = Pathname.new(options[:output]).expand_path(@env.cwd)
          raise Vagrant::Errors::VagrantfileExistsError if save_path.exist?
        end

        template_path = ::Vagrant.source_root.join("templates/commands/init/Vagrantfile")
        contents = Vagrant::Util::TemplateRenderer.render(template_path,
                                                          :box_name => argv[0] || "base",
                                                          :box_url => argv[1])

        if save_path
          # Write out the contents
          begin
            save_path.open("w+") do |f|
              f.write(contents)
            end
          rescue Errno::EACCES
            raise Vagrant::Errors::VagrantfileWriteError
          end

          @env.ui.info(I18n.t("vagrant.commands.init.success"), prefix: false)
        else
          @env.ui.info(contents, prefix: false)
        end

        # Success, exit status 0
        0
      end
    end
  end
end

=end
          
        end
      end       
    end    
  end
end
