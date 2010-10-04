class CreateProfileAwards < ActiveRecord::Migration
  def self.up
    create_table :profile_awards do |t|
      t.integer  :profile_id
      t.integer  :award_id
    end
  end

  def self.down
    drop_table :profile_awards
  end
end
