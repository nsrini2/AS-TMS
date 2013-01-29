class IncreaseProfileQuestionSizes < ActiveRecord::Migration
  def self.up
    change_column :profiles, :skills_expertise, :string, :limit => 1000
    change_column :profiles, :places_traveled, :string, :limit => 1000
    change_column :profiles, :favorite_hobbies, :string, :limit => 1000
    change_column :profiles, :favorite_music, :string, :limit => 1000
    change_column :profiles, :places_dream_about, :string, :limit => 1000
    change_column :profiles, :for_a_living, :string, :limit => 1000
    change_column :profiles, :gigs_contacts, :string, :limit => 1000
    change_column :profiles, :favorite_watering_hole, :string, :limit => 1000
    change_column :profiles, :favorite_sports, :string, :limit => 1000
    change_column :profiles, :celebrity_most_like, :string, :limit => 1000
  end

  def self.down
  end
end
