class CreateShowcaseMarketingMessages < ActiveRecord::Migration
  def self.up
    create_table :showcase_marketing_messages do |t|
      t.boolean :active
      t.text :link_to_url

      t.timestamps
    end
  end

  def self.down
    drop_table :showcase_marketing_messages
  end
end
