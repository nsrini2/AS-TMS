class CreateFavorite < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.string :custom_title, :null => true
      t.timestamps
      t.integer :offer_id, :null => false
      t.integer :user_id, :null => false
    end
  end

  def self.down
    drop_table :favorites
  end
end
