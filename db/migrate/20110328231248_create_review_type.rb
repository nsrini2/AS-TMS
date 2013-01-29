class CreateReviewType < ActiveRecord::Migration
  def self.up
    create_table :review_type do |t|
      t.timestamps
      
      t.string :review_type
      t.integer :review_id
    end
  end

  def self.down
  end
end
