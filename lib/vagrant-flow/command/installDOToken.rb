require "vagrant"
require 'optparse'
require 'yaml'


module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class InstallDOKey < Vagrant.plugin("2", :command)
        
        # Builtin from Command class
        # Must override to provide a description
        def self.synopsis
          "Installs your digital ocean key to ~/.vagrant-flow"
        end

        def commandThread(machine,command, quiet)
          begin
            machine.communicate.execute(command)
            if !quiet
              puts "Command was ran successfully on: "+machine.config.vm.hostname
            end
          rescue
            if !quiet
              puts "Command FAILED on: "+machine.config.vm.hostname
              @error_message="#{$!}"
              puts @error_message
            end
          ensure
            if !quiet
              puts "----"
            end
          end
        end
        
        # Builtin from Command class
        # Must override to provide core functionality
        def execute
          options = {}
          options[:destroy_on_error] = true
          options[:parallel] = false
          options[:provision_ignore_sentinel] = false
          options[:quiet] = false
          options[:token] = nil

          opts = OptionParser.new do |o|
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow multicommand [-qf] -c COMMAND\n"+
                        "Installs your digital ocean key for easy vagrant-flow configuration"
            o.separator ""

            o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
              options[:quiet] = true
            end
            
            o.on("-t", "--token TOKEN", "(REQUIRED) The token to install") do |f|
              options[:token] = f
            end
          end
          
          argv = parse_options(opts)
          return if !argv
          raise OptionParser::MissingArgument if options[:token].nil?
          x = {
            :digitalOceanToken=>options[:token],
          }
          
          filename = ENV['HOME']+"/.vagrant-flow"
          begin
            File.open(filename, 'w') { |file| file.write (x.to_yaml ) }
          rescue
            @error_message="#{$!}"
            $stderr.puts "Could not write to "+filename
            $stderr.puts @error_message
          end
          
          
          #Require my library for talking to digitalocean
          require File.expand_path(File.dirname(__FILE__) ) +"/getDOKey"
          puts getKey()
          
        end
      end
    end
  end
end

