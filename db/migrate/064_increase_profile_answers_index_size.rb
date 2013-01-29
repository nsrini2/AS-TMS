class IncreaseProfileAnswersIndexSize < ActiveRecord::Migration

  def self.up
    change_column :profile_text_indices, :answers_text, :text, :limit => 16777215
  end

  def self.down
  end

end
