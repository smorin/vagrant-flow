require 'yaml'

##Example usage:
##Require my library for talking to digitalocean
##require File.expand_path(File.dirname(__FILE__) ) +"/getDOToken"
##puts GetDOToken.getToken()

class GetDOToken
    
    #Returns digital ocean token that's been installed
    #Returns nil if its not present
    def self.getToken()
      filename = ENV['HOME']+"/.vagrant-flow"
      if File.exists?(filename)
        x =  YAML::load_file(filename)
        if x.has_key?(:digitalOceanToken)
           return x[:digitalOceanToken]
        end
      end
      return nil
    end
end




