class AddUserSyncJobs < ActiveRecord::Migration
  
  def self.up
    create_table :user_sync_jobs do |t|
      t.string :status
      t.timestamp :start_time
      t.timestamp :end_time
      t.text :options
      t.text :response_hash
      t.string :response_message
    end
    execute "ALTER TABLE user_sync_jobs ADD COLUMN log_output MEDIUMTEXT" # mediumtext=16mb
    execute "ALTER TABLE user_sync_jobs ADD COLUMN data MEDIUMTEXT" # mediumtext=16mb
  end

  def self.down
    drop_table :user_sync_jobs
  end
  
end
