class AddKarmaHistoriesMonthIndex < ActiveRecord::Migration
  def self.up
    add_index :karma_histories, [:profile_id, :month, :year],  { :name => "karma_month_index", :unique => true }
  end

  def self.down
    remove_index :karma_histories, :name => :karma_month_index
  end
end
