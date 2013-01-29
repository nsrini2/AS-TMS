class CreateSiteQuestionCategories < ActiveRecord::Migration
  def self.up
    create_table :site_question_categories do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :site_question_categories
  end
end
