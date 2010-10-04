class CreateSiteProfileQuestions < ActiveRecord::Migration
  def self.up
    create_table :site_profile_questions do |t|
      t.string :label
      t.string :question
      t.string :example
      t.boolean :completes_profile
      t.boolean :matchable
      t.integer :site_profile_question_section_id

      t.timestamps
    end
  end

  def self.down
    drop_table :site_profile_questions
  end
end
