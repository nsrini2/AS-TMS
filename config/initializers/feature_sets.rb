feature_set_config = YAML.load(File.read("#{Rails.root}/config/feature_sets.yml"))

FEATURE_ACTIVITY_STREAM_ADS = feature_set_config.member?("activity_stream_ads") && feature_set_config["activity_stream_ads"]
FEATURE_ELASTIC_SEARCH = feature_set_config.member?("elastic_search") && feature_set_config["elastic_search"]