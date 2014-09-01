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


        # Builtin from Command class
        # Must override to provide core functionality
        def execute
          options = {}
          options[:destroy_on_error] = true
          options[:parallel] = false
          options[:provision_ignore_sentinel] = false
          options[:nowrite] = false
          options[:quiet] = false
          options[:digitalocean] = false
          options[:digitalocean_file] = "multiinitconfig.yml"

          #Parse option, look up OptionParser documentation
          opts = OptionParser.new do |o|
            # o.banner = "Usage: vagrant ansible-inventory [vm-name] [options] [-h]"
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow multicommand [-qdf]\n"+
                        "Runs a shell command on all the machines in your vagrantfile"
            o.separator ""

            o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
              options[:quiet] = true
            end
            
            o.on("-d", "--digitalocean", "(Optional) Use this option to communicate with digital ocean machines.  Default file is multiinitconfig.yml") do |f|
              options[:digitalocean] = true
            end
            
            o.on("-f", "--multiinitconfig FILE", "(Optional) File to read in for config instead of multiinitconfig.yml") do |f|
              options[:digitalocean_file] = f
            end
          end
          argv = parse_options(opts)
          return if !argv
          

          with_target_vms(argv, :provider => options[:provider]) do |machine|
            return unless machine.communicate.ready?
          end
        end
      end
    end
  end
end
