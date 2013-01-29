class CreateSponsorAccount < ActiveRecord::Migration
  def self.up
    create_table :sponsor_accounts, :force => true do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :sponsor_accounts
  end
end
