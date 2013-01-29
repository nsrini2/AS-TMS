require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Profile do
  before(:each) do
    User.delete_all
    Profile.delete_all
    
    @profile = Profile.new()
    @user = User.new()
    @user.login = 'test'
    @user.email = 'test@cubeless.com'
    @user.valid?
    @valid_attributes = {
      :first_name => 'first',
      :last_name => 'last',
      :screen_name => 'test',
      :user => @user
    }
  end
  it "should create a new instance given valid attributes" do
    @profile.attributes = @valid_attributes
    puts @profile.valid?
    puts @profile.errors.full_messages
    @profile.should be_valid
  end
  it "should be invalid without a first name" do
    @profile.attributes = @valid_attributes.except(:first_name)
    @profile.should have(1).error_on(:first_name)
  end
  it "should be invalid without a last name" do
    @profile.attributes = @valid_attributes.except(:last_name)
    @profile.should have(1).error_on(:last_name)
  end
  it "should be invalid without a screen name" do
    @profile.attributes = @valid_attributes.except(:screen_name)
    @profile.should have(1).error_on(:screen_name)
  end
  it "should be invalid without a User" do
    @profile.attributes = @valid_attributes.except(:user)
    @profile.should have(1).error_on(:user)
  end
  
  describe 'Karma' do
    before(:each) do
      @profile.attributes = @valid_attributes
      @profile.valid?
    end
    it "should not be negative" do
      @profile.karma_points = -1
      @profile.valid?
      @profile.karma_points.should be(0)
    end
    it "should not be over Karma maximum when set manually" do
      @profile.karma_points = Karma.karma_max + 1
      @profile.valid?
      @profile.karma_points.should be(Karma.karma_max)
    end
    it "should not be over Karma maximum when set with Profile.add_karma!" do
      Profile.stub!(:find).and_return(@profile)
      Profile.add_karma!(@profile.id, Karma.karma_max + 1)
      @profile.reload
      @profile.karma_points.should be(Karma.karma_max)
    end
  end
  
  describe 'Profile Completion' do
    # before(:each) do
    #       @profile.attributes = @valid_attributes
    #       @profile.save
    # end
    before(:each) do
      @qhash = {"q1" => "one","q2" => "two","q3" => "three","q4" => "four", "q5" => "five" }
      @fhash = {"f1" => "one","f2" => "two","f3" => "three","f4" => "four" }
      @profile.attributes = @valid_attributes
    end
    
    it "should find the total number of complex questions" do
      Profile.stub!(:profile_complex_questions).and_return(@qhash)
      Profile.profile_complex_questions_total.should == 5
    end
    
    it "should find the total number of fields" do
      Profile.stub!(:profile_biz_card_questions).and_return(@fhash)
      Profile.profile_biz_card_fields_total.should == 4
    end

    it "should find the total number of complex questions" do
      Profile.stub!(:profile_complex_questions).and_return(@qhash)
      Profile.profile_complex_questions_total.should == Profile.profile_complex_questions.size
    end
    
    it "should find the total number of fields" do
      Profile.stub!(:profile_biz_card_questions).and_return(@fhash)
      Profile.profile_biz_card_fields_total.should == Profile.profile_biz_card_questions.size
    end
    
    it "should return if a field is required to compelte the profile" do
      @profile.question_field_required?("profile_1").should be_true 
    end
    
    it "should return false if field is not present" do
      @profile.question_field_required?("NOTHING_RESONBLE_HERE123XX").should be_false       
    end
    
    it "should return all total number of fields that compelete the profile" do
      @profile.all_fields_total.should_not  == 0
    end
    
    it "should return all total number of fields greater than 0" do
      @profile.all_fields_total.should  > 0
    end
    
    it "should return all biz card fields count" do
      @profile.biz_cards_fields_profile_total.should <= @profile.all_fields_total
    end
    
    it "should return 8 or less fields count" do
      @profile.biz_cards_fields_profile_total.should <= 8   
    end
    
    it "should return at least one field static email count" do
      @profile.biz_cards_fields_profile_total.should >= 1   
    end
        
    it "should return all complex questions count" do
      @profile.complex_questions_profile_total.should <= @profile.all_fields_total
    end
    
    it "should return a total complex questions count greater than or equal to 0" do
      @profile.complex_questions_profile_total.should >= 0    
    end
    
    it "should return 20 or less questions" do
      @profile.complex_questions_profile_total.should <= 20   
    end
    
    it "should return all biz card fields that are required to compelete the profile" do
      @profile.biz_cards_fields_completes_profile_total.should >= 1
    end
    
    it "should return biz card fields completes profile total less than biz card fields profile total" do
      @profile.biz_cards_fields_completes_profile_total.should <= @profile.biz_cards_fields_profile_total  
    end
    
    it "should return biz card fields completes profile total less than all fields total" do
      @profile.biz_cards_fields_completes_profile_total.should <=  @profile.all_fields_total  
    end
    
    it "should return all complex questions that are required to complete the profile" do
      @profile.complex_questions_completes_profile_total.should >= 0 
    end
    
    it "should return all complex questions that are required to compelete the profile" do
      @profile.complex_questions_profile_total.should >= 0
    end
    
    it "should return complex questions completes profile total less than all fields total" do
      @profile.complex_questions_profile_total.should <= @profile.all_fields_total  
    end
    
    it "should return biz card fields are not completed " do
      @profile.biz_card_fields_completed.should >= 0
    end
    
    it "should return complex questions count that completes profile" do
      Profile.profile_complete_fields.size.should >= 0
    end
    
    it "should return greater than 0 biz card fields that are incomplete" do
      @profile.biz_card_fields_incomplete.should > 0
    end

    it "should return greater than 0 complex questions that are incomplete" do
      @profile.complex_questions_incomplete > 0
    end
    
    it "should return biz cards are complete be completed and return false" do
      @profile.biz_card_complete?.should be_false
    end
    
    it "should report complex questions completed and return false" do
      @profile.biz_card_complete?.should be_false
    end
    
    it "should return biz card fields count that are completed " do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("profile_")  
         cnt += 1 
         @profile.send("#{v}=", "A Pithy Fact About Me #{Time.now.to_s}")  if @profile.respond_to?(v) 
       end 
      end
      @profile.biz_card_fields_completed.should == cnt
    end
        
    it "should return complex questions count that are completed " do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("question_")
         cnt += 1 
         @profile.send("#{v}=", "What A Pithy Question #{Time.now.to_s}") if @profile.respond_to?(v) 
       end 
      end
      @profile.complex_questions_completed.should == cnt
    end

    it "should report biz cards are complete be completed and return true" do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("profile_")  
         cnt += 1 
         @profile.send("#{v}=", "A Pithy Fact About Me #{Time.now.to_s}")  if @profile.respond_to?(v) 
       end 
      end
      @profile.biz_card_complete?.should be_true
    end

    it "should return complex questions count that are completed " do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("question_")
         cnt += 1 
         @profile.send("#{v}=", "What A Pithy Question #{Time.now.to_s}") if @profile.respond_to?(v) 
       end 
      end
      @profile.complex_questions_completed.should == cnt
    end
    
    it "should report complex questions completed and return false" do      
      @profile.complex_questions_complete?.should be_false
    end
    
    it "Should return the label for profile_1" do
       @profile.biz_card_labels("profile_1").should_not == nil
    end
    
    it "should have 0 complete fields" do
        @profile.how_complete == 0
    end

    it "should return how complete total completed fields" do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("profile_")  
         cnt += 1 
         @profile.send("#{v}=", "A Pithy Fact About Me #{Time.now.to_s}")  if @profile.respond_to?(v) 
       end 
      end
      cnt =0;
      Profile.profile_complete_fields.each do |v|
       if v.index("question_")
         cnt += 1 
         @profile.send("#{v}=", "What A Pithy Question #{Time.now.to_s}") if @profile.respond_to?(v) 
       end 
       
      end
      @profile.how_complete.should == @profile.complex_questions_completed + @profile.biz_card_fields_completed 
    end
    
    it "should return how complete total for a sponsored user only" do
      @profile.add_roles Role::SponsorMember
      @profile.how_complete.should ==  @profile.biz_card_fields_completed
      @profile.remove_roles Role::SponsorMember
    end
    
    it "should not be a sponsored account" do 
      @profile.sponsor_account_id?.should be_false
    end
    
    it "should be complete " do
      @profile.how_complete.should != @profile.biz_card_fields_completed
    end
    
    it "should return biz card completion percentage completion for sponsored account" do
      @profile.add_roles Role::SponsorMember
      @profile.completion_percentage.should ==  @profile.biz_card_completion_percentage
      @profile.remove_roles Role::SponsorMember     
    end
    
    it "should return complex question +  completion percentage completion for sponsored account" do
      @profile.add_roles Role::SponsorMember
      @profile.completion_percentage.should ==  ( @profile.complex_question_completion_percentage.to_f + 
                                                  @profile.biz_card_completion_percentage.to_f)/2
      @profile.remove_roles Role::SponsorMember     
    end
    
    it "should calculate 0% biz card profile completion" do
      @profile.biz_card_completion_percentage.should == 0
    end

    it "should calculate 0% complex questions profile completion" do
      @profile.complex_question_completion_percentage.should == 0
    end
    
    it "should calcualte to 100% biz card profile completion" do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("profile_")  
         cnt += 1 
         @profile.send("#{v}=", "A Pithy Fact About Me #{Time.now.to_s}")  if @profile.respond_to?(v) 
       end 
      end
      @profile.biz_card_completion_percentage.to_i.should == 100
    end
    
    it "should calcualte to 100% complex question for profile completion" do
      cnt = 0;
      Profile.profile_complete_fields.each do |v|
       if v.index("question_")
         cnt += 1 
         @profile.send("#{v}=", "What A Pithy Question #{Time.now.to_s}") if @profile.respond_to?(v) 
       end 
      end
      @profile.complex_question_completion_percentage.to_i.should == 100
    end
    
    it "should calculate < 100% biz card profile completion" do
      cnt = 1;
      Profile.profile_complete_fields.each do |v|
       if v.index("profile_")  
         cnt += 1 
         @profile.send("#{v}=", "A Pithy Fact About Me #{Time.now.to_s}")  if @profile.respond_to?(v) && cnt != 1
         @profile.send("#{v}=", nil) if cnt == 1
       end 
      end
      @profile.biz_card_completion_percentage.to_i.should == 100
    end
    
    it "should calculate < 100% complex question for profile completion" do
      cnt = 1;
      Profile.profile_complete_fields.each do |v|
       if v.index("question_")
         cnt += 1 
         @profile.send("#{v}=", "What A Pithy Question #{Time.now.to_s}") if @profile.respond_to?(v) && cnt != 1
          @profile.send("#{v}=", nil) if cnt == 1 
       end 
      end
      @profile.complex_question_completion_percentage.to_i.should == 100
    end
  end
  
  describe "statuses" do
    it "should have many statuses" do
      @profile.should respond_to(:statuses)
    end
  end
end


