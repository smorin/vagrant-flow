require "vagrant"
require 'optparse'
require 'tempfile'
require 'yaml'

#Require my library for talking to digitalocean
require File.expand_path(File.dirname(__FILE__) ) +"/digitalocean_api"

module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class MultiCommand < Vagrant.plugin("2", :command)
        
        # Builtin from Command class
        # Must override to provide a description
        def self.synopsis
          "Runs a command on all the machines in your vagrantfile"
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
          options[:filter] = []

          opts = OptionParser.new do |o|
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow multicommand [-qf] -c COMMAND\n"+
                        "Runs a shell command on specified machines in your vagrantfile"
            o.separator ""

            o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
              options[:quiet] = true
            end
            
            o.on("-f", "--filterMachine VMNAME,VNAME2...", Array, "(Optional) comma separated list of machines to run command on") do |f|
              options[:filter] = f
            end
            
            o.on("-c", "--command COMMAND", "(REQUIRED) Command to run on the machines") do |f|
              options[:command] = f
            end
          end
          argv = parse_options(opts)
          return if !argv
          raise OptionParser::MissingArgument if options[:command].nil?
          
          threads = []
          
          with_target_vms(argv, :provider => options[:provider]) do |machine|
            #return unless machine.communicate.ready?
            if options[:filter].empty? or options[:filter].include? machine.config.vm.hostname
              threads.push(Thread.new{commandThread(machine,options[:command],options[:quiet])})
            end
          end
          
          threads.each {|t|
            t.join
          }
          
        end
      end
    end
  end
end
