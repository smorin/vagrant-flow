require "net/http"
require "uri"
require "json"

class DigitalOcean_Api
  
  def initialize(digitaloceanurl= 'https://api.digitalocean.com', digitaloceanpath="/v2/droplets")
      @DIGITALOCEAN_URL=digitaloceanurl
      @DIGITALOCEAN_PATH=digitaloceanpath
  end
  
  #params should be a hash that will be in the form of
  #{"Authorization"=>"Bearer ~~DIGITALOCEANTOKEN~~"}
  def makeApiCall(params)

    uri = URI.parse(@DIGITALOCEAN_URL)
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(@DIGITALOCEAN_PATH)

    request.initialize_http_header(params)
    response = http.request(request)
    return JSON.parse(response.body)
  end
  
  
  #returns parsed hash object from returned json
  def showAllActiveDroplets(token)
    x = {
      "Authorization" => "Bearer "+token
    }
    return makeApiCall(x)
  end
  
  #Calls showAllActiveDroplets and then parses the info for just hostname and ip
  def getHostNamesAndIps(token)
    hash = showAllActiveDroplets(token)
    returnHash = []
    
    hash["droplets"].each {|droplet|
        #Grab the IP information for each droplet
        #Each IP is contained in an array, so extract that
        ip = []
        droplet["networks"]["v4"].each do |x|
          ip.push(x["ip_address"])
        end
        
        #Usually there's only the one IP address per machine,
        #this will help with backwards compatibility
        if ip.length == 1
          ip = ip[0]
        end
        
        
        returnHash.push({
                          :hostname => droplet["name"],
                          :ip       => ip
                          })
      }
    return returnHash
  end
  
end




