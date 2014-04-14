require "net/http"
require "uri"
require "json"
require "uri"

class DigitalOcean_Api
  
  def initialize(digitaloceanurl= 'https://api.digitalocean.com/droplets/?')
      @DIGITALOCEAN_URL=digitaloceanurl
  end
  
  #getparams should be a hash that will get turned into a url
  def makeApiCall(getparams)
    url = @DIGITALOCEAN_URL + URI.encode_www_form(getparams)
    
    response = Net::HTTP.get_response(URI.parse(url))
    
    return JSON.parse(response.body)
  end
  
  #https://api.digitalocean.com/droplets/?client_id=xxxxxxx&api_key=yyyyyyyyyy
  #returns parsed hash object from returned json
  def showAllActiveDroplets(clientId,apiKey)
    x = {
      "client_id" => clientId,
      "api_key"   => apiKey,
    }
    return makeApiCall(x)
  end
  
  #Calls showAllActiveDroplets and then parses the info for just hostname and ip
  def getHostNamesAndIps(clientId,apiKey)
    hash = showAllActiveDroplets(clientId,apiKey)
    returnHash = []
    hash["droplets"].each {|droplet|
        returnHash.push({
                          :hostname => droplet["name"],
                          :ip       => droplet["ip_address"]
                          })
      }
    return returnHash
  end
  
end




