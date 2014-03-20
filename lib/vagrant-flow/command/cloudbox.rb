require 'optparse'
require "vagrant"
require "yaml"

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
        end
      end       
    end    
  end
end
