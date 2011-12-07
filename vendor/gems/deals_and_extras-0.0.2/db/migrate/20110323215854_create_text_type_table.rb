class CreateTextTypeTable < ActiveRecord::Migration
  def self.up
    create_table :text_types do |t|
      t.timestamps
      
      t.string :text_type
    end
  end

  def self.down
  end
end
