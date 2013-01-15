Tire.configure do
  # point to the elasticsearch host
  if Rails.env.development?
    url "http://localhost:9200"
    # SSJ 11-15-2012 unset the http_proxy for RestClient
    # I believe Tire is the only gem that is using RestClient
    # the proxy creates issues on development 
    RestClient.proxy = nil
  elsif Rails.env.production?
    staging_config = YAML.load(File.read("#{Rails.root}/config/facebook.yml"))
    # staging/as2
    if staging_config['fb_app_id'] == '214583051896993'
      url "10.20.212.71:9201"
    else
      url "10.20.212.71:9200"
    end
  end
  # rake environment tire:import CLASS=Comment FORCE=true
  # logger STDERR
  # logger
  
  # configure Tire to work with Log4r
  mylog  = Rails.logger
  mylog.instance_eval do
    alias :write :info
    # alias :<< :info
    def << (*args)
      nil
    end
  end
  
  logger mylog
end
