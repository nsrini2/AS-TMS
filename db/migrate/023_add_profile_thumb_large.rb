class AddProfileThumbLarge < ActiveRecord::Migration
  
  def self.up
    ProfilePhoto.find(:all).each do |p|
      p.save!
    end
  end
  
  def self.down
    ProfilePhoto.find(:all).each do |p|
      p.save!
    end
  end
  
end