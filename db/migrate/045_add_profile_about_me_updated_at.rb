class AddProfileAboutMeUpdatedAt < ActiveRecord::Migration
  def self.up
    add_column :profiles, :about_me_updated_at, :datetime
  end

  def self.down
    remove_column :profiles, :about_me_updated_at
  end
end
