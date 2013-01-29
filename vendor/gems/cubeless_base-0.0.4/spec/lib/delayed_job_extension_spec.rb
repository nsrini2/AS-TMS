require File.dirname(__FILE__) + '/../spec_helper'

describe "DelayedJobExtensions" do
  it "should be an ancestor of Delayed::Job " do
    # Delayed::Job.ancestors.include?(DelayedJobExtensions).should == true -- non rspec notation
    Delayed::Job.ancestors.should include DelayedJobExtensions
  end  
  
  it "should override named_scope :ready_to_run" do
    pending "figure out how to test in Rails 3"
    @now = Time.now
    Time.stub!(:now).and_return(@now)
    
    expected_options = { :conditions => ['(run_at <= ? AND locked_at IS NULL) AND failed_at IS NULL', @now ] }
    Delayed::Job.ready_to_run('worker', 4.hours).proxy_options.should == expected_options    
  end    
  
end  

describe "DelayedPerformableMailerExtensions" do
  class SpecNotifier < ActionMailer::Base
    def self.one
      []
    end
    
    def two
      mail(:to => "scott.johnson@sabre.com")
    end
  end
  
  before(:each) do
    @notifier = SpecNotifier
    @mail = SpecNotifier.two
    SpecNotifier.stub!(:two).and_return(@mail)
    @array = SpecNotifier.one
    SpecNotifier.stub!(:one).and_return(@array)
  end
  
  it "should call .deliver on Mail::Message objects that get delayed" do
    dpm = Delayed::PerformableMailer.new(@notifier, :two, [])
    @mail.should_receive(:deliver).and_return(true)
    dpm.perform
  end
  
  it "should NOT call .deliver on objects that are not of class Mail::Message that get delayed" do
    dpm = Delayed::PerformableMailer.new(@notifier, :one, [])
    @array.should_not_receive(:deliver)
    dpm.perform
  end  
end  