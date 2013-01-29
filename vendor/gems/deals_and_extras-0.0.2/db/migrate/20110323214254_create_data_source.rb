class CreateDataSource < ActiveRecord::Migration
  def self.up
    create_table :data_sources do |t|
      t.timestamps
      
      t.string :data_source
    end
  end

  def self.down
  end
end
