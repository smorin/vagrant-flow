require "vagrant"
require 'optparse'
require 'tempfile'

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
        end
        
      end       
    end    
  end
end
