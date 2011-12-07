class SiteProfileQuestion < ActiveRecord::Base
  include Config::Callbacks

  belongs_to :site_profile_question_section

  class << self
    def max_fields
      12
    end
    def questions_available
      max_fields - count
    end
    def questions_available?
      questions_available > 0
    end

    def question_names
      (1..12).to_a.collect { |i| "question_#{i}"}
    end
    def question_names_available
      all_qn = question_names
      all.collect{ |f| all_qn.delete(f.question) }
      all_qn
    end
  end

end
