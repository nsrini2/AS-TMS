module MailerSpecHelper
  def read_fixture(action, namespace=nil)    
    path = [namespace, action].compact.join("/")
    IO.readlines("#{RAILS_ROOT}/spec/fixtures/mailers/notifiers/#{path}.html")
  end
end

module EmailMatcher
  class Email
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual

      @actual.from.to_s == @expected.from.to_s &&
      @actual.to.to_s == @expected.to.to_s &&
      @actual.subject.to_s == @expected.subject.to_s &&
      !@expected.body.blank? &&
      @actual.body.to_s.include?(@expected.body.to_s)
    end

    def failure_message
      "expected <#{to_string(@actual)}> to " +
      "the same as <#{to_string(@expected)}>"
    end

    def negative_failure_message
      "expected <#{to_string(@actual)}> not to " +
      "be the same as <#{to_string(@expected)}>"
    end

    # Returns string representation of an object.
    def to_string(value)
      # indicate a nil
      if value.nil?
        'nil'
      end

      # join arrays
      if value.class == Array
        return value.join(", ")
      end

      # otherwise return to_s() instead of inspect()
      return value.to_s
    end
  end

  # Actual matcher that is exposed.
  def match_email(expected)
    Email.new(expected)
  end
end

# Spec::Matchers.create :match_email do |expected|
#   match do |actual|
#     match_from(actual, expected)
#   end
# 
#   def match_from(actual, expected)
#     actual.from.should == expected.from
#   end
# end