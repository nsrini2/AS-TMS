class ChangeProfileQuestions < ActiveRecord::Migration
  def self.up
    add_column :profiles, :hometown, :string
    rename_column :profiles, :places_been, :places_traveled
    add_column :profiles, :live_now, :string
    rename_column :profiles, :favorite_dream_destinations, :places_dream_about
    
    add_column :profiles, :for_a_living, :string
    rename_column :profiles, :travel_advice_on, :skills_expertise
    add_column :profiles, :gigs_contacts, :string
    add_column :profiles, :favorite_watering_hole, :string
    
    add_column :profiles, :favorite_sports, :string
    rename_column :profiles, :things_love_to_do, :favorite_hobbies
    rename_column :profiles, :favorite_music_bands_artists, :favorite_music
    add_column :profiles, :celebrity_most_like, :string
    
    remove_column :profiles, :favorite_movies_tv_shows
    remove_column :profiles, :favorite_books_authors 
  end
  
  def self.down
    remove_column :profiles, :hometown
    rename_column :profiles, :places_traveled, :places_been
    remove_column :profiles, :live_now
    rename_column :profiles, :places_dream_about, :favorite_dream_destinations
    
    remove_column :profiles, :for_a_living
    rename_column :profiles, :skills_expertise, :travel_advice_on
    remove_column :profiles, :gigs_contacts
    remove_column :profiles, :favorite_watering_hole
    
    remove_column :profiles, :favorite_sports
    rename_column :profiles, :favorite_hobbies, :things_love_to_do
    rename_column :profiles, :favorite_music, :favorite_music_bands_artists
    remove_column :profiles, :celebrity_most_like
    
    add_column :profiles, :favorite_movies_tv_shows, :string
    add_column :profiles, :favorite_books_authors, :string    
  end
end