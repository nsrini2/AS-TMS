class RemoveShoutOuts < ActiveRecord::Migration
  def self.up
    drop_table :shout_outs
  end

  def self.down
    raise 'no going back!'
  end
end
