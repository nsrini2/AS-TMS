require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserPasswordValidator do
  class UserPasswordValidator
    def initialize
      #simulating everything "on"
      @min_length = 6
      @max_length = 10
      @req_alpha = 1
      @req_numeric = 1
      @req_upper_lower = 1
      @req_special = 1
      @max_sequential_chars = 2
      @max_repeating_chars = 2
      
      error_defs = []
      error_defs << [:min_length,"Password must be at least #{@min_length} characters."] if @min_length
      error_defs << [:max_length,"Password cannot be longer than #{@max_length} characters."] if @max_length
      error_defs << [:req_alpha,"Password must contain at least #{@req_alpha} letter#{'s' if @req_alpha>1}."] if @req_alpha
      error_defs << [:req_numeric,"Password must contain at least #{@req_numeric} number#{'s' if @req_numeric>1}."] if @req_numeric
      error_defs << [:upper_lower,"Password must contain both lower and upper case letters."] if @req_upper_lower
      error_defs << [:max_repeating,"Cannot have more than #{@max_repeating_chars} repeating characters. (ex: 1111)"] if @max_repeating_chars>1
      error_defs << [:max_sequential,"Cannot have more than #{@max_sequential_chars} sequential characters. (ex: abcd,1234)"] if @max_sequential_chars>1

      @verbal_rules = error_defs.collect { |(k,v)| v }
      @errors_map = error_defs.inject({})  { |h,(k,v)| h[k] = v; h }
    end
  end
  
  before(:each) do
    @validator = UserPasswordValidator.new
  end
  
  it "should return an error when a password is too short" do
    @validator.validate("pass").should include("Password must be at least 6 characters.")
  end

  
  it "should return an error when a password is too long" do
    @validator.validate("superlongpassword").should include("Password cannot be longer than 10 characters.")
  end
  
  it "should return an error when no letters are used" do
    @validator.validate("123").should include("Password must contain at least 1 letter.")
  end
  
  it "should return an error when no numbers are used" do
    @validator.validate("abc").should include("Password must contain at least 1 number.")
  end
  
  it "should return an error when both lower and upper case letters are not used" do
    @validator.validate("abc").should include("Password must contain both lower and upper case letters.")
    @validator.validate("ABC").should include("Password must contain both lower and upper case letters.")
  end

  it "should return an error when there are too many repeating chars" do
    @validator.validate("aa").should_not include("Cannot have more than 2 repeating characters. (ex: 1111)")
    @validator.validate("aaa").should include("Cannot have more than 2 repeating characters. (ex: 1111)")
  end
  
  it "should return an error when there are too many sequential chars" do
    @validator.validate("123").should include("Cannot have more than 2 sequential characters. (ex: abcd,1234)")
  end

  it "should not return an error when a password is long enough" do
    @validator.validate("password").should_not include("Password must be at least 6 characters.")
  end
  
  it "should not return an error when a password is shorter than the max length" do
    @validator.validate("short").should_not include("Password cannot be longer than 10 characters.")
  end
  
  it "should not return an error when at least 1 letter is used" do
    @validator.validate("123a").should_not include("Password must contain at least 1 letter.")
  end
  
  it "should not return an error when at least 1 number is used" do
    @validator.validate("abc1").should_not include("Password must contain at least 1 number.")
  end
  
  it "should not return an error when both lower and upper case letters are used" do
    @validator.validate("abcABC").should_not include("Password must contain both lower and upper case letters.")
  end

  it "should not return an error when there no repeating chars" do
    @validator.validate("a1a").should_not include("Cannot have more than 2 repeating characters. (ex: 1111)")
  end
  
  it "should not return an error when there are no sequential chars" do
    @validator.validate("a1a").should_not include("Cannot have more than 2 sequential characters. (ex: abcd,1234)")
  end
end