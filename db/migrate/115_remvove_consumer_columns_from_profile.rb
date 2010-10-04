class RemvoveConsumerColumnsFromProfile < ActiveRecord::Migration
  def self.up
     remove_column :profiles, :city
     remove_column :profiles, :state
     remove_column :profiles, :country
     remove_column :profiles, :relative_age
     remove_column :profiles, :marital_status
     remove_column :profiles, :gender
  end

  def self.down
  end
end
