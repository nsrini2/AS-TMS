
class InitialSchema < ActiveRecord::Migration
  
  def self.up
        
    create_table :users do |t|
      t.column :screen_name,               :string, :null => false
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime, :null => false
      t.column :updated_at,                :datetime, :null => false
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime            
    end
    add_index :users,:screen_name,:unique => true
    

    create_table :questions do |t|
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :open_until, :date, :null => false
      t.column :profile_id, :integer, :null => false
      t.column :question, :text, :null => false     
    end
    add_index :questions, :profile_id
    add_index :questions, :created_at
    add_index :questions, :open_until
   
    create_table :profiles do |t|
      t.column :user_id, :integer, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :tag_line, :string   
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :keep_name_private, :boolean
      t.column :city, :string
      t.column :state, :string
      t.column :country, :string
      t.column :keep_location_private, :boolean
      t.column :relative_age, :string
      t.column :marital_status, :string
      t.column :gender, :string
      t.column :travel_advice_on, :string
      t.column :places_been, :string
      t.column :things_love_to_do, :string
      t.column :favorite_music_bands_artists, :string
      t.column :favorite_movies_tv_shows, :string
      t.column :favorite_books_authors, :string
      t.column :favorite_dream_destinations, :string
      t.column :exclude_terms, :text
    end
    add_index :profiles, :user_id, :unique => true

    create_table :answers do |t|      
      t.column :created_at, :datetime, :null => false
      t.column :profile_id, :integer, :null => false
      t.column :question_id, :integer, :null => false
      t.column :answer, :text, :null => false
    end
    add_index :answers, :profile_id
    add_index :answers, :question_id
    add_index :answers, :created_at
    
   
  end
  
  def self.down
    drop_table :questions
    drop_table :users
    drop_table :answers
    drop_table :profiles
  end
  
end
