require File.dirname(__FILE__) + '/../../spec_helper'

require 'ruport'

describe Reports::Associations do    
  before(:each) do
    # User.destroy_all
    # Profile.destroy_all
    Group.destroy_all
    GroupMembership.destroy_all
    
    @profile = create_user_and_profile(:login => 'direct_member', :roles => Role::DirectMember)        
    @group = Group.create!(:name => "Test Group", :description => "Testig", :tags => "testing", :last_updated_by => @profile.id, :owner => @profile)
    # @group_membership = GroupMembership.create!(:group_id => @group.id, :profile_id => @profile.id)
    @group_membership = @group.group_memberships.first
    @report_group = Reports::Group.last
  end

  def test_user
    @user = @profile.user
    
    puts @user.class
    
    @user.should be_is_a(User)
    @user.should_not be_is_a(Reports::User)    
  end
  def test_profile
    @profile = Profile.last
    
    puts @profile.class
    
    @profile.should be_is_a(Profile)
    @profile.should_not be_is_a(Reports::Profile)    
  end
  def test_group
    @group = Group.last
    
    puts @group.class
    
    @group.should be_is_a(Group)
    @group.should_not be_is_a(Reports::Group)    
  end
  def test_group_membership
    @group_membership = @group.group_memberships.last

    puts @group_membership.class
    
    @group_membership.should be_is_a(GroupMembership)
    @group_membership.should_not be_is_a(Reports::GroupMembership)    
  end
  def test_report_group
    @report_group = Reports::Group.last
    
    puts @report_group.class
    
    @report_group.should be_is_a(Reports::Group)
    @report_group.should be_is_a(Group)    
  end
  def test_report_group_membership
    @report_group_membership = @report_group.group_memberships.last
    
    puts @report_group_membership.class
    
    @report_group_membership.should be_is_a(Reports::GroupMembership)
    @report_group_membership.should be_is_a(GroupMembership)    
  end
  def test_report_group_member
    @report_group_member = @report_group.members.last
    
    puts @report_group_member.class
    
    @report_group_member.should be_is_a(Reports::Profile)
    @report_group_member.should be_is_a(Profile)
  end

  def test_all
    test_user
    test_profile
    
    test_group
    test_group_membership
    
    test_report_group
    test_report_group_membership    
    test_report_group_member
  end
  
  def test_all_reverse
    test_report_group
    test_report_group_membership
    test_report_group_member

    test_group
    test_group_membership
    
    test_user
    test_profile
  end


  it "should not totally jack up all ActiveRecord Associations" do
    test_all
    
    test_all
  end
  
  it "should not totally jack up all ActiveRecord Associations" do
    test_all_reverse
    
    test_all_reverse
    
    test_all
  end
  
end