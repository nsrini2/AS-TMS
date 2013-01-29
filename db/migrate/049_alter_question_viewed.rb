class AlterQuestionViewed < ActiveRecord::Migration
  def self.up
    remove_column :questions, :viewed_at
    add_column :questions, :viewed_at, :datetime
    execute "update questions set viewed_at = now()"
    change_column :questions, :viewed_at, :datetime
  end
end
