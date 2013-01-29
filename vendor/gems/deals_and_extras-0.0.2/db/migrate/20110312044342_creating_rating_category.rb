class CreatingRatingCategory < ActiveRecord::Migration
  def self.up
    create_table :rating_categories do |t|
      t.string :rating_category, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :rating_categories
  end
end
