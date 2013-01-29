class CreateSiteProfileQuestionSections < ActiveRecord::Migration
  def self.up
    create_table :site_profile_question_sections do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :site_profile_question_sections
  end
end
