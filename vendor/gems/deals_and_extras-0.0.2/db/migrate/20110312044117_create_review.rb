class CreateReview < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :offer_id, :null => false
      t.boolean :rating, :null => false
      t.integer :rating_category_id, :null => false
      t.string :review
      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
