require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    # stubb SabreRedWorkspaceTicket get ticket from XML fixture in lieu of external API
    class SRWT < SabreRedWorkspaceTicket
      class << self
        def get_ticket(fixture)
          IO.read(fixture)
        end
      end
    end
    # Create Stubbs      
    @@valid_ticket = SRWT.new( File.expand_path(File.dirname(__FILE__) + '/../fixtures/srw_valid_ticket.xml') )
    @@invalid_ticket = SRWT.new( File.expand_path(File.dirname(__FILE__) + '/../fixtures/srw_invalid_ticket.xml') )
    @@valid_ticket_bad_email = SRWT.new( File.expand_path(File.dirname(__FILE__) + '/../fixtures/srw_valid_ticket_no_email.xml') )
    @@existing_user = User.new()
    @@existing_user.login = 'test'
    @@existing_user.email = 'test@sabre.com'
    @@existing_user.save!
  end  
  
  it "should respond with an Expired Ticket Error if the ticket is expired" do   
    assert(!@@invalid_ticket.valid?)
    assert_equal("Expired Ticket KbkyATT0f1ShzF97AZ1UvfkO62e507e4", @@invalid_ticket.error)
  end
  
  it "should have the proper params if it is valid" do 
    assert(@@valid_ticket.valid?)
    test_params = {"agentid"=>"888888", "city"=>"TULSA", "region"=>"NA", "country"=>"US", "language"=>"EN", "lastname"=>"Johnson", "pcc"=>"95TB", "valid"=>"true", "phone"=>"..", "firstname"=>"Scott", "agencyname"=>"TNSS", "email"=>"scott.johnson@sabre.com"}
    assert_equal(test_params, @@valid_ticket.params) 
  end
  
  it "should respond_to :email, :to_s and :not_a_valid_method_or_element" do
    # hash element
    assert @@valid_ticket.respond_to?(:email)
    # super
    assert @@valid_ticket.respond_to?(:to_s)
    # non-hash element nor super method
    assert !@@valid_ticket.respond_to?(:not_a_valid_method_or_element)
  end
   
  it "should create a new agentstream user if one does not exist with the provided AgentID_PCC" do
    user = @@valid_ticket.find_or_create_agentstream_user
    profile = user.profile
    assert profile.valid?
    assert user.valid?
    assert_equal("#{@@valid_ticket.agentid}_#{@@valid_ticket.pcc}", user.srw_agent_id  ) #
    reg_field_values = profile.profile_registration_fields.collect { |p| p.site_registration_field_id = 2; p.value }
    assert reg_field_values.size == 4
    assert(reg_field_values.include? @@valid_ticket.city.to_s )
    assert(reg_field_values.include? @@valid_ticket.country.to_s )
    assert(reg_field_values.include? @@valid_ticket.pcc.to_s )
    assert(reg_field_values.include? @@valid_ticket.agencyname.to_s )
  end   
   
  it "should do something graceful if user/profile cannot be created, like if the ticket lacks a valid email" do
    Rails.logger.should_receive(:error).exactly(4).times.and_return(true)
    user = @@valid_ticket_bad_email.find_or_create_agentstream_user
    user.should be_nil
  end  

end
