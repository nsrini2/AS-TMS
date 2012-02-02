feature_set_config = YAML.load(File.read("#{Rails.root}/config/feature_sets.yml"))

ACTIVITY_STREAM_ADS = feature_set_config["activity_stream_ads"]