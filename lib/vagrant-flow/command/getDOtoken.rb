require 'yaml'

class GetDOKey
    def getKey()
      filename = ENV['HOME']+"/.vagrant-flow"
      x =  YAML::load_file(filename)
      return x[:digitalOceanToken]
    end
end




