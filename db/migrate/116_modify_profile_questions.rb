class ModifyProfileQuestions < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :hometown_city, :question_1
    change_column :profiles, :question_1, :string, :limit => 1000

    rename_column :profiles, :live_now_city, :question_2
    change_column :profiles, :question_2, :string, :limit => 1000

    # question_1 = question_1 + hometown_country
    # question_2 = question_2 + live_now_country
    execute "update profiles set
      question_1=if(length(trim(concat_ws('',question_1,hometown_country))),concat_ws(', ',if(length(trim(question_1)),trim(question_1),null),if(length(trim(hometown_country)),trim(hometown_country),null)),null),
      question_2=if(length(trim(concat_ws('',question_2,live_now_country))),concat_ws(', ',if(length(trim(question_2)),trim(question_2),null),if(length(trim(live_now_country)),trim(live_now_country),null)),null)"

    remove_column :profiles, :hometown_country
    remove_column :profiles, :live_now_country

    rename_column :profiles, :places_traveled, :question_3
    rename_column :profiles, :places_dream_about, :question_4
    rename_column :profiles, :for_a_living, :question_5
    rename_column :profiles, :gigs_contacts, :question_6
    rename_column :profiles, :skills_expertise, :question_7
    rename_column :profiles, :favorite_watering_hole, :question_8
    rename_column :profiles, :favorite_sports, :question_9
    rename_column :profiles, :favorite_music, :question_10
    rename_column :profiles, :favorite_hobbies, :question_11
    rename_column :profiles, :celebrity_most_like, :question_12
  end

  def self.down
    rename_column :profiles, :question_1, :hometown_city
    change_column :profiles, :hometown_city, :string, :limit => 255
    add_column :profiles, :hometown_country, :string, :limit => 255

    rename_column :profiles, :question_2, :live_now_city
    change_column :profiles, :live_now_city, :string, :limit => 255
    add_column :profiles, :live_now_country, :string, :limit => 255

    rename_column :profiles, :question_3, :places_traveled
    rename_column :profiles, :question_4, :places_dream_about
    rename_column :profiles, :question_5, :for_a_living
    rename_column :profiles, :question_6, :gigs_contacts
    rename_column :profiles, :question_7, :skills_expertise
    rename_column :profiles, :question_8, :favorite_watering_hole
    rename_column :profiles, :question_9, :favorite_sports
    rename_column :profiles, :question_10, :favorite_music
    rename_column :profiles, :question_11, :favorite_hobbies
    rename_column :profiles, :question_12, :celebrity_most_like
  end
end
