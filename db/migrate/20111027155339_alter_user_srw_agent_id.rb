class AlterUserSrwAgentId < ActiveRecord::Migration
  def self.up
    change_column :users, :srw_agent_id, :string 
  end
  
  def self.down
    change_column :users, :srw_agent_id, :int
  end
end
