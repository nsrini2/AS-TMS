class TempSiteProfileQuestion < ActiveRecord::Base
  set_table_name :site_profile_questions
end

class AddPositionToSiteProfileQuestion < ActiveRecord::Migration
  def self.up
    add_column :site_profile_questions, :position, :integer
    
    TempSiteProfileQuestion.reset_column_information
    
    TempSiteProfileQuestion.all.group_by(&:site_profile_question_section_id).each do |section_id, questions|
      questions.each_with_index do |q, idx|
        q.update_attribute(:position, idx+1)
      end
    end
    
  end

  def self.down
    remove_column :site_profile_questions, :position   
  end
end
