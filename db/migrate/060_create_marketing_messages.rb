class CreateMarketingMessages < ActiveRecord::Migration
  def self.up
    create_table :marketing_messages do |t|
      t.column "default", :boolean, :default => 0
      t.column "active", :boolean, :default => 0
      t.column "link_to_url", :text
    end
  end

  def self.down
    drop_table :marketing_messages
  end
end