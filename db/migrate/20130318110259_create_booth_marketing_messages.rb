class CreateBoothMarketingMessages < ActiveRecord::Migration
  def self.up
    create_table :booth_marketing_messages do |t|
      t.boolean :active
      t.text :link_to_url
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :booth_marketing_messages
  end
end
