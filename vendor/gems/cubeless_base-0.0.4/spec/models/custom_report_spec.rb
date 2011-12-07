require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CustomReport do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :form => "value for form"
    }
  end

  it "should create a new instance given valid attributes" do
    CustomReport.create!(@valid_attributes)
  end

  describe "sarah's report" do
    it "should have lots of things inside" do
      path = File.exist?("#{Rails.root}/spec/fixtures") ? "#{Rails.root}/spec/fixtures/sarah_report_output.csv" : "#{CubelessBase::Engine.root}/spec/fixtures/sarah_report_output.csv"
      
      CustomReport.sarah_report(path)
    end
  end

end
