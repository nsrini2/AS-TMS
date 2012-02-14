class AlterParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :presenter, :boolean, :default => false
    add_column :participants, :bio, :text
  end

  def self.down
    drop_column :participants, :presenter   
    drop_column :participants, :bio   
  end
end
