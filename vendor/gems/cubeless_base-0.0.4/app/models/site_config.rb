# Handles general site config
# Presence of config/my_config.yml is still required for certain attributes including:
#
#   smtp_settings:
#     !ruby/sym address: 'etomail.aln.sabre.com'
#     !ruby/sym port: 25
#     !ruby/sym domain: 'cubeless.com'
#
#   session_key: 'cubeless_xxx'
#   session_secret: '123467'
#
#   tfce_sso_my_domain: 'cubeless'
#   tfce_sso_domain: 'destination'
#   tfce_sso_url: 'https://sso.sabre.com/cubelessSignOn.aspx' 
#   tfce_sso_secret: '123456'
# 
#   tfce_sso_portal_url: "https://sso.sabre.com/cubelessProfile"
#   tfce_sso_portal_url_text: "my portal profile"


class SiteConfig < ActiveRecord::Base
  xss_terminate :except => [ :feedback_email, :email_from_address, :analytics_tracker_code, :monitor_email_address ]


  has_many :site_logos, :as => :owner
  has_many :site_favicons, :as => :owner  

  def logo_file
    site_logos.empty? ? nil : site_logos.last.public_filename
  end
  def favicon
    site_favicons.empty? ? nil : site_favicons.last.public_filename
  end
  def question_categories
    # SiteQuestionCategory.find_by_sql("SELECT name FROM site_question_categories ORDER BY position").collect{ |qc| qc.name }
    SiteQuestionCategory.find(:all, :order => :position).collect{ |qc| qc.name }
  end
  def profile_biz_card_questions
    SiteProfileField.all
  end
  def contact_info_order
    # fields = SiteProfileField.find(:all, :include => [:site_profile_page, :site_biz_card])
    # {'profile' => fields.select{ |f| f.site_profile_page.position > 0 }.sort_by{ |f| f.site_profile_page.position }.collect{ |f| f.question },
    #   'business_card' => fields.select{ |f| f.site_biz_card.position > 0 }.sort_by{ |f| f.site_biz_card.position }.collect{ |f| f.question }}
    
    {'profile' => SiteProfilePage.find(:all, :conditions => "position > 0", :order => :position, :include => [:site_profile_field]).collect{ |spp| spp.site_profile_field.question },
      'business_card' => SiteBizCard.find(:all, :conditions => "position > 0", :order => :position, :include => [:site_profile_field]).collect{ |sbc| sbc.site_profile_field.question }}
  end
  def profile_complex_questions
    qs = []
    SiteProfileQuestionSection.find(:all, :order => :position, :include => [:site_profile_questions]).each_with_index do |spqs, idx|      
      qs << {'title' => spqs.name,
              'questions' => spqs.site_profile_questions}
    end
    qs
  end
  
  def registration_fields
    # This actually doesn't work due to the load order
    # The SiteConfig#open_registration has not been loaded yet... :/
    # if Config[:open_registration]
    #   SiteRegistrationField.find(:all, :order => :position).collect{ |srf| {'label' => srf.label, 'id' => srf.id} }
    # else
    #   []
    # end
    SiteRegistrationField.find(:all, :order => :position).collect{ |srf| {'label' => srf.label, 
                                                                          'id' => srf.id, 
                                                                          'required' => srf[:required],
                                                                          'options' => srf[:options].to_s} }
  end

  
  alias :default_attributes :attributes
  
  # def attributes
  #   {'logo_file' => logo_file,
  #     'favicon' => favicon,
  #     'question_categories' => question_categories,
  #     'profile_biz_card_questions' => profile_biz_card_questions,
  #     'contact_info_order' => contact_info_order,
  #     'profile_complex_questions' => profile_complex_questions,
  #     'registration_fields' => registration_fields}.merge(default_attributes)
  # end
  
  def custom_attributes
    # {'logo_file' => logo_file,
    #   'favicon' => favicon,
    {
      'question_categories' => question_categories,
      'profile_biz_card_questions' => profile_biz_card_questions,
      'contact_info_order' => contact_info_order,
      'profile_complex_questions' => profile_complex_questions,
      'registration_fields' => registration_fields}
  end
  
  def method_missing(method_name, *args)
    if self.custom_attributes[method_name.to_s]
      self.custom_attributes[method_name.to_s]
    else
      super
    end
  end
  
end
