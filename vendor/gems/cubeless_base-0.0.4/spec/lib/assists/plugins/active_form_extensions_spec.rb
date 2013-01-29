require File.dirname(__FILE__) + '/../../../spec_helper'

describe ActiveForm do
  
  it "should extend methods from ActiveFormExtensions::ClassMethods" do
    ActiveForm.should respond_to(:self_and_descendents_from_active_record)
  end
  
end