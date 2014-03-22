#Flush stdout immediately
$stdout.sync = true

require "vagrant"
require 'optparse'
require 'yaml'
require 'pty'

module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class Playbook < Vagrant.plugin("2", :command)
        
        # Builtin from Command class
        # Must override to provide a description
        def self.synopsis
          "Runs ansible-playbook so you don't have to!"
        end
        
        
        # Builtin from Command class
        # Must override to provide core functionality
        def execute
          options = {}
          options[:destroy_on_error] = true
          options[:parallel] = false
          options[:provision_ignore_sentinel] = false
          options[:configfile] = "flow-playbook.yml"
          options[:print] = false
          options[:quiet] = false
          
          #Parse option, look up OptionParser documentation 
          opts = OptionParser.new do |o|
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow playbook [-hfpq]\n"+
                        "Reads in config from flow-playbook.yml by default to be able to run ansible-playbook more easily"
            o.separator ""
           
            o.on("-f", "--file-playbook FILE", "(Optional) Use a specified playbook config file instead of default (flow-playbook.yml)") do |f|
              options[:configfile] = f
            end
            
            o.on("-p", "--print-only", "(Optional) Don't actually ansible-playbook, but just output what would be run to STDOUT") do |f|
              options[:print] = true
            end
            
            o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
              options[:quiet] = true
            end
            
          end
          argv = parse_options(opts)
          return if !argv
          
          config={}
          begin
            #Load YAML
            config = YAML.load_file(options[:configfile])
          rescue
            #Give warning if no file could be found
            if not options[:quiet]
              warn "Could not open file: "+options[:configfile].to_s
            end
          end
          
          #Bail out if config is fubar
          if not config.has_key?(:playbook)
            if not options[:quiet]
              warn options[:configfile].to_s+" is missing \":playbook\" key"
            end
            return
          end
          
          if not config.has_key?(:inventory)
            if not options[:quiet]
              warn options[:configfile].to_s+" is missing \":inventory\" key"
            end
            return
          end
          
          #Build the ansible-playbook command
          command = "ansible-playbook "
          if config.has_key?(:pattern)
            command+= "-l "+config[:pattern]+" "
          end
          command+= "-i "+config[:inventory]+" "
          command+= config[:playbook]
          
          #If print is specified, only output the command
          if options[:print]
            #But only print if the quiet command isn't specified 
            if not options[:quiet]
              puts command
            end
          else
            
          
          #Run the command
          #this fancy block of code outputs the output in real time
          begin
            PTY.spawn( "#{command}" ) do |stdin, stdout, pid|
              begin
                stdin.each { |line|
                  if not options[:quiet]
                    puts line
                  end
                }
                #This wait() is required to set the exit code
                Process.wait(pid)
              rescue Errno::EIO
              end
            end
          rescue PTY::ChildExited
            #If there was an error, throw an error ourselves
            raise Vagrant::Errors::AnsibleFailed
          end
          
          #If there was an error, throw an error ourselves
          raise Vagrant::Errors::AnsibleFailed if not $?.success?
            
          end
        end
        
      end       
    end    
  end
end
