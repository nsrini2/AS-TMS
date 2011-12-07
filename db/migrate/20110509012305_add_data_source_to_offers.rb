class AddDataSourceToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :data_source_id, :integer
  end

  def self.down
    remove_column :offers, :data_source_id
  end
end
