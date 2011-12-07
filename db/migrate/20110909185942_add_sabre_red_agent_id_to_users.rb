class AddSabreRedAgentIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :srw_agent_id, :int
    add_column :users, :srw_ticket, :text
  end

  def self.down
    remove_column :users, :srw_agent_id
    remove_column :users, :srw_ticket
  end
end
