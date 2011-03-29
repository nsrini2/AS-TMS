if RAILS_ENV['development']
  # Setup Proxy
  # RestClient.proxy = "http://proxy.example.com/"
  #
  # Or inherit the proxy from the environment:
  #
  RestClient.proxy = ENV['http_proxy']
  RestClient.log = Rails.logger
end