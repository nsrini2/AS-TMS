class ProxyUtil

  # returns a proxy-enabled Net::HTTP
  # uri can have an encoded user/pass, or you can specify them separate
  def self.net_http(use_proxy=true,uri=nil,username=nil,password=nil)
    return Net::HTTP unless use_proxy
    return @@default_net_http unless uri
    create_net_http(uri,username,password)
  end

  private

  def self.create_net_http(uri,username=nil,password=nil)
    return Net::HTTP unless uri
    uri = URI.parse(uri)
    username,password = uri.userinfo.to_s.split(/:/) unless username
    Net::HTTP::Proxy(uri.host,uri.port,username,password)
  end

  @@default_net_http = create_net_http(ENV['http_proxy'])

end