class AddProfileFieldsToProfile < ActiveRecord::Migration
  def self.up
    8.upto(12) do |i|
      add_column :profiles, "profile_#{i}", :string
    end
  end

  def self.down
    8.upto(12) do |i|
      remove_column :profiles, "profile_#{i}"
    end 
  end
end
