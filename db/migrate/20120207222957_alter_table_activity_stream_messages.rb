class AlterTableActivityStreamMessages < ActiveRecord::Migration
  def self.up
    add_column :activity_stream_messages, :subline, :string
  end

  def self.down
    drop_column :activity_stream_messages, :subline   
  end
end
