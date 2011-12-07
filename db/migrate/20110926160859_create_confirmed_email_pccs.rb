class CreateConfirmedEmailPccs < ActiveRecord::Migration
  def self.up
    create_table :confirmed_email_pccs do |t|
      t.string :email
      t.string :pcc

      t.timestamps
    end
  end

  def self.down
    drop_table :confirmed_email_pccs
  end
end
