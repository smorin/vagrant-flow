require "vagrant"
require 'optparse'
require 'tempfile'

module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class HostFile < Vagrant.plugin("2", :command)
        
        # Builtin from Command class
        # Must override to provide a description
        def self.synopsis
          "Sets /etc/hosts so that all your machines can communicate with each other"
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
          
          #Parse option, look up OptionParser documentation 
          opts = OptionParser.new do |o|
            # o.banner = "Usage: vagrant ansible-inventory [vm-name] [options] [-h]"
            o.banner = "A NeverWinterDP technology from the Department of Badass.\n\n"+
                        "Usage: vagrant flow hostfile [-hnkq]\n"+
                        "Edits all your VMs /etc/hosts file to be able to find all the machines on your private network"
            o.separator ""
           
            o.on("-q", "--quiet", "(Optional) Suppress output to STDOUT and STDERR") do |f|
              options[:quiet] = true
            end
            
            o.on("-n", "--no-write-hosts", "(Optional) Don't actually write a new hosts file to the guest machine") do |f|
              options[:nowrite] = true
            end
          end
          argv = parse_options(opts)
          return if !argv
          
          
          hostinfo=[]
          #Go through config
          #Map hostnames to IP's
          with_target_vms(argv, :provider => options[:provider]) do |machine|
            return unless machine.communicate.ready?
            hostname = machine.config.vm.hostname
            machine.config.vm.networks.each {|networks|
              networks.each {|net|
                if net.is_a?(Hash) and net.has_key?(:ip)
                  hostinfo.push(
                    {
                        :hostname=>hostname,
                        :ip=>net[:ip]
                    })
                end                
              }
            }
          end
          
          #What we're going to add to the end of the guest's hostfile
          #A combination of IP's and hostnames
          toconcatenate="\n"+"##ADDED BY NEVERWINTERDP'S VAGRANT-FLOW HOSTFILE COMMAND"+"\n"
          hostinfo.each {|x|
            toconcatenate+=x[:ip]+"   "+x[:hostname]+"\n"
          }
          
          
          #Read in guest's current hosts file
          #Append our new entries to it
          #Write it out onto the guest's hosts file
          with_target_vms(argv, :provider => options[:provider]) do |machine|
            return unless machine.communicate.ready?
            
            #This block of code was shamelessly stolen from
            #https://github.com/smdahlen/vagrant-hostmanager/blob/master/lib/vagrant-hostmanager/hosts_file.rb
            #Why reinvent the wheel?
            #Determines what the move command and where /etc/hosts should be for linux, windows, and sunOS
            if (machine.communicate.test("uname -s | grep SunOS"))
              realhostfile = '/etc/inet/hosts'
              move_cmd = 'mv'
            elsif (machine.communicate.test("test -d $Env:SystemRoot"))
              realhostfile = "#{ENV['WINDIR']}\\System32\\drivers\\etc\\hosts"
              move_cmd = 'mv -force'
            else 
              realhostfile = '/etc/hosts'
              move_cmd = 'mv'
            end
            
            #Back to my code
            #Grab Vagrant's temp file location
            guesthostfilepath = @env.tmp_path.join("hosts."+machine.config.vm.hostname)
            #Download guest's hosts file
            machine.communicate.download(realhostfile, guesthostfilepath)
            
            #Append our hostname/IP info to the end of the hosts file
            guesthostfile = File.open(guesthostfilepath,"a")
            guesthostfile.write(toconcatenate)
            guesthostfile.close()
            
            if not options[:nowrite]  
              #Upload updated hosts file to guest to temp location
              machine.communicate.upload(guesthostfile.path, '/tmp/hosts')
              #Move temp file over on top of hosts file
              machine.communicate.sudo(move_cmd+" /tmp/hosts "+realhostfile)  
            end
          end
          
          
            
        end
        
      end       
    end    
  end
end
