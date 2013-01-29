class AddHashToOffer < ActiveRecord::Migration
  def self.up
    add_column :offers, :hash_id, :string
  end

  def self.down
  end
end
