require 'yaml'
require 'erb'

module Config
  
  #!H major hack, discovered this is a ruby low-level module... need to move this later
  @@h = {}
  
  def self.full_hash
    @@h
  end
  
  def self.require(key)
    self[key] || raise("#{key} not specified in Config")
  end
  
  def self.[](key)
    @@h[key.to_s]
  end
  
  def self.merge!(hash)
    @@h.merge!(hash)
  end
  
  def self.fetch(key,default=nil,&block)
    @@h.fetch(key.to_s,default,&block)
  end
  
  def self.merge_config(name,required=true)
    filepath = File.exists?("#{Rails.root}/config/#{name}.yml") ? "#{Rails.root}/config/#{name}.yml" : "#{CubelessBase::Engine.root}/config/#{name}.yml"
    Config.merge!(YAML::load(ERB.new(IO.read(filepath)).result)) if required || File.exist?(filepath)
  end
  
  def self.load_config 
    config_path = File.exists?("#{Rails.root}/config/config.yml") ? "#{Rails.root}/config/config.yml" : "#{CubelessBase::Engine.root}/config/config.yml"
    all_config = YAML::load(ERB.new(IO.read(config_path)).result)
    Config.merge!(all_config['global'])
    Config.merge!(all_config[Rails.env]) if all_config[Rails.env]
    merge_config('my_config',false) # loads local config settings
    merge_config('theme')
    # cubeless_config, customer_config, etc.
    merge_config("#{Config[:config]}_config")
    merge_config('my_config',false) # allow any 'my' settings to override loaded :config settings
  end
  
  ###
  ### Preloading configs from yml file to the db
  ###
  def self.populate_config_db    
    # Ensure there is a site config
    site_config = populate_site_config

    # Ensure there is a theme
    populate_site_theme
    
    # Ensure question categories are loaded into db
    populate_question_categories
    
    # Profile fields
    populate_profile_fields
    
    # Profile questions
    populate_profile_questions
    
    site_config
  end
  
  def self.populate_site_config
    site_config = SiteConfig.first
    
    unless site_config
      site_config = SiteConfig.new
      sc_attributes = Config.full_hash.dup.delete_if do |k,v| 
        !site_config.default_attributes.has_key?(k)
      end      
      
      # Account for crazy analytics codes
      # Sometimes set to false but should always be a string
      sc_attributes['analytics_tracker_code'] ||= ""
      
      site_config = SiteConfig.create!(sc_attributes)
    end
    
    site_config
  end
  
  def self.populate_site_theme
    unless Config[:theme]
      sc.update_attributes!(:theme => "theme_1")
    end
  end
  
  def self.populate_question_categories
    if SiteQuestionCategory.count == 0
      Config[:question_categories].to_a.each_with_index do |c, idx|
        SiteQuestionCategory.create(:name => c, :position => idx+1)
      end
    end
  end

  def self.populate_profile_fields
    if SiteProfileField.count == 0
      # Ensure an 'email' profile field exists
      SiteProfileField.create(:label => "Email", :question => "email")
      
      # Load in profile fields from config
      Config[:profile_biz_card_questions].to_a.each do |f|
        unless f['question'] == "email"
          SiteProfileField.create(f)
        end
      end
      
      # Load in profile cards from config
      Config[:contact_info_order]['profile'].to_a.each_with_index do |p, idx|
        SiteProfilePage.create(:site_profile_field_id => SiteProfileField.find_by_question(p).id, :position => idx+1)
      end
      Config[:contact_info_order]['business_card'].to_a.each_with_index do |p, idx|
        SiteBizCard.create(:site_profile_field_id => SiteProfileField.find_by_question(p).id, :position => idx+1)
      end
    end
  end
  
  def self.populate_profile_questions
    if SiteProfileQuestionSection.count == 0
      Config['profile_complex_questions'].to_a.each_with_index do |q, idx|
        section = SiteProfileQuestionSection.create(:name => q['title'], :position => idx+1)
 
        q['questions'].each do |question|
          SiteProfileQuestion.create(question.merge({:site_profile_question_section_id => section.id}))
        end
      end
    end
  end
  
  def self.clear_db_config!
    SiteConfig.delete_all
    SiteQuestionCategory.delete_all
    SiteProfileQuestionSection.delete_all
    SiteProfileQuestion.delete_all
    SiteProfileField.delete_all
    SiteProfileCard.delete_all
  end
  
  
  def self.load_config_from_db(options={})     
    if !Config['last_updated_at']
      # Look for the first SiteConfig db entry
      sc = SiteConfig.first
    
      # Populating the config should really only be done once...ever
      if !sc
        sc = Config.populate_config_db
      end
    
      # Merge the configs
      merge_db_config(sc, options)
    else
      scs = SiteConfig.find_by_sql("SELECT updated_at FROM site_configs ORDER BY id LIMIT 1")
      sc_last_updated_at = scs.first.updated_at
      
      if Config['last_updated_at'] != sc_last_updated_at
        sc = SiteConfig.first
        
        merge_db_config(sc, options)
      end
    end
  end
  
  # Merge the db config with the Config
  def self.merge_db_config(site_config, options={})
    # puts "TRYING TO DB MERGE CONFIG"
    
    # Grab the config attributes
    site_config_attributes = site_config.custom_attributes.merge!(site_config.attributes)
  
    # Remove attrs that don't contribute
    site_config_attributes.delete_if do |k,v| 
      v.nil? || 
      (v.is_a?(String) && v.blank?)
    end
  
    # Merge the config
    Config.merge!(site_config_attributes)
    
    # Update the last update time
    Config.merge!({ 'last_updated_at' => site_config.updated_at })
    
    # Run rake tasks when specified
    #`rake tmp:cache:clear bam:generate_css asset:packager:build_all`
    if options[:reload_assets]
      FileUtils.rm_rf(Dir['tmp/cache/[^.]*'])
      CSS.new.generate
      Synthesis::AssetPackage.build_all
    end
  end
  
  
  
  module Callbacks
    
    def after_save
      touch_config_updated_at
    end
    def after_destroy
      touch_config_updated_at
    end
    
    def touch_config_updated_at
      SiteConfig.first.update_attribute(:updated_at, Time.now)
    end
    
  end
  
end

