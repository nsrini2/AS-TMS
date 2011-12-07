class ProfileTextIndex < ActiveRecord::Base

  belongs_to :profile

  xss_terminate :except => self.column_names

  def add_answer(answer_id,answer_text)
    self.answers_text = '' if !self.answers_text
    self.answers_text << "<qa id=\"#{answer_id}\">#{answer_text}</qa>"
  end

  def remove_answer(answer_id)
    # removes the xml syntax based on id
    self.answers_text.gsub!(Regexp.new("<qa id=\"#{answer_id}\">.+?<\/qa>",Regexp::MULTILINE),'') if self.answers_text
  end

  def all_answers_text
    return '' if self.answers_text.nil?
    result = self.answers_text
    result.gsub!(Regexp.new("<qa id=\"\\d+\">",Regexp::MULTILINE),' ')
    result.gsub!(Regexp.new("<\/qa>",Regexp::MULTILINE),' ')
    result
  end

end
