# sample url -- ticket is expired:
# https://my.cert.sabre.com/validateTicket.jsp?ticketNo=KbkyATT0f1ShzF97AZ1UvfkO62e507e4

class SabreRedWorkspaceTicket
  # SSJ Aug 2011
  # This class is used to parse the XML returned by the Sabre Red Workspace(SRW) Ticket Validator
  # into an object that can be easily inspected and manage the SSO relations between
  # SRW and AgentStream
  # 
  # Example Use:
  # ticket = SabreRedWorkspaceTicket.new(ticketNo)
  # return unless ticket.valid?
  # if ticket.linked_to_agent_stream_user?
  #   self.current_user = ticket.agent_stream_user
  # else
  #   # create new AgentStream user
  #   current_user = ticket.find_or_create_agentstream_user
  #   ... 
  # end
    
   
  def initialize(ticket_id)
    ticket = self.class.get_ticket(ticket_id)
    # have to call self. here otherwise Ruby creates a 
    # local variable ticket_hash assigns the value then tosses it
    self.ticket_hash = self.class.parse_ticket(ticket)
  end
    
  def valid?
    # cannot call self. here because ticket_hash is private    
    ticket_hash.valid && ticket_hash.valid == "true"
  end
  
  def respond_to?(method)
    ticket_hash.respond_to?(method.to_sym) || super   
  end
  
  def params
    ticket_hash.to_hash
  end
  
  def agent_stream_profile
    user = agent_stream_user
    if user
      user.profile
    end  
  end
  
  def agent_stream_user
    return nil unless self.valid?
    @agent_stream_user ||= User.find_by_srw_agent_id(self.build_srw_agent_id)
    update_agentstream_user_srw_info(@agent_stream_user) if @agent_stream_user 
  end
  
  def update_agentstream_user_srw_info(as_user)
    unless as_user.srw_ticket == self.to_json
      as_user.srw_ticket = self.to_json
      as_user.save
    end  
    as_user
  end
  
  def to_json
    ticket_hash.to_json
    rescue
      {}.to_json
  end
  
  def build_srw_agent_id
    "#{self.agentid}_#{self.pcc.to_s}"
  end
  
  def country_name
    Country.find_by_srw_country_code(self.country).name
    rescue NoMethodError
      # if a matching Country is not found, just return the SWR code provided
      self.country
  end
  
  def find_or_create_agentstream_user
    # double chek user dose not exist before creating it
    if !agent_stream_user && self.valid?
      # create new user and profile for agent_stream
      user = User.new
      user.srw_agent_id = self.build_srw_agent_id
      # create a unique login
      user.login = "#{self.lastname}-SRW#{User.select('id').last.id + 1}"
      profile = Profile.new(:user => user)
      profile ||= user.profile
      user.email = self.email
      profile.first_name = self.firstname
      profile.last_name = self.lastname
      profile.status = 1
      profile.screen_name = "#{profile.first_name} #{profile.last_name}"
      profile.roles = [Role::DirectMember]
      # AgentStream Specific
      profile.profile_5 = self.region + " " + self.country
      profile.profile_1 = self.agencyname
      Profile.transaction do
        user.save! && profile.save!
      end
      profile_registration_values = [{:site_registration_field_id => 5, :value => self.city}]
      profile_registration_values << {:site_registration_field_id => 4, :value => self.country_name} 
      profile_registration_values << {:site_registration_field_id => 1, :value => self.pcc} 
      profile_registration_values << {:site_registration_field_id => 2, :value => self.agencyname}
      
      profile_registration_values.each do |params|
        prf = profile.profile_registration_fields.new(params)
        prf.save!
      end      
    end 
    agent_stream_user
    rescue Exception => e
      Rails.logger.error "An error occurred creating a user from SRW"
      Rails.logger.error self.inspect
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.inspect
      nil    
  end

  def method_missing(method)
    # this makes the ticket_hash methods appear like 
    # instance methods
    # everything is donwcase to avoid errors
    m = method.to_s.downcase.to_sym
    super unless ticket_hash.respond_to?(m)
    ticket_hash.send(m)
  end


private  
  attr_accessor :ticket_hash
  
class << self
  def get_ticket(ticket_id)
    # Made switch for testing
    # response = test_ticket_xml(true)
    begin
      response = RestClient.get(ticket_url(ticket_id))
    rescue  
      response = "<?xml version='1.0' encoding='UTF-8'?><Ticket valid='false'>Invalid Ticket</Ticket>"
    end
    response  
  end
  
  def parse_ticket(xml)
    h =Hash.from_xml(xml)["Ticket"]
    if h.is_a?(String)
      h = {"error" => h, "valid" => "false"}
    end  
    # lets normalize keys to all downcase
    h2 = h.inject({}) { |hash, (k, v)| hash.merge! k.downcase.to_sym => v  }
    Hashie::Mash.new(h2)
  end
    
  def ticket_url(ticket_no= "")
   # check to see if we are on agentstream.com or not
   # Using the Facebook APP_ID to determine this
   unless FB_APP_ID == '191254297585014'
     cert = ".cert"
   end   
   "https://my#{cert}.sabre.com/validateTicket.jsp?ticketNo=#{ticket_no}"
  end
  
  def link_users(to_user, from_user)
    to_user.srw_agent_id = from_user.srw_agent_id
    to_user.srw_ticket = from_user.srw_ticket
    from_user.srw_agent_id = nil
    from_user.srw_ticket = "linked to user: #{to_user.id}"
    from_profile = from_user.profile
    from_profile.status = -1
    if User.transaction {from_user.save!; from_profile.save!; to_user.save! }
      to_user
    else
      false 
    end  
  end
  
  # SSJ -- I just put this here to make developining in console easier
  def test_ticket_xml(valid=true)
    if valid
      xml = IO.read('test/fixtures/srw_valid_ticket.xml')
    else
      xml = IO.read('test/fixtures/srw_invalid_ticket.xml')
    end    
  end
end
  
end  
