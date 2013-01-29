class AddRatingsToTripElements < ActiveRecord::Migration
  def self.up

    create_table :ratings do |t|
      t.integer :rater_id, :null => false
      t.integer :rated_id, :null => false
      t.string  :rated_type, :null => false
      t.integer :rating, :null => false, :default => 0
    end

    add_index :ratings, :rater_id
    add_index :ratings, [:rated_type, :rated_id, :rater_id], :unique => true

    add_column :trip_elements, :rating_count, :integer, :null => false, :default => 0
    add_column :trip_elements, :rating_total, :integer, :null => false, :default => 0
    add_column :trip_elements, :rating_avg,   :decimal, :precision => 10, :scale => 2, :null => false, :default => 0

    add_index :trip_elements, :rating_avg

  end

  def self.down

    remove_column :trip_elements, :rating_count
    remove_column :trip_elements, :rating_total
    remove_column :trip_elements, :rating_avg

    drop_table :ratings

  end
end
