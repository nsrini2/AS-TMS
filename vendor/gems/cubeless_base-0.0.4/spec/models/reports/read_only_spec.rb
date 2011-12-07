require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::ReadOnly do
  class MyUser < ActiveRecord::Base
    set_table_name "users"
    
    include Reports::ReadOnly
  end
    
  it "should not save objects" do
    lambda{ MyUser.new.save }.should raise_error(ActiveRecord::ReadOnlyRecord)
  end
  it "should not be able to destroy an object" do
    pending "great 2011 migration"
    lambda{ MyUser.new.destroy }.should raise_error(ActiveRecord::ReadOnlyRecord)
  end
end