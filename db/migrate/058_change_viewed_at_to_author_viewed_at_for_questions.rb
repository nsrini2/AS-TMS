class ChangeViewedAtToAuthorViewedAtForQuestions < ActiveRecord::Migration
  def self.up
    rename_column :questions, :viewed_at, :author_viewed_at
  end

  def self.down
    rename_column :questions, :author_viewed_at, :viewed_at
  end
end
