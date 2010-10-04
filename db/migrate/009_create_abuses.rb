class CreateAbuses < ActiveRecord::Migration
  
  def self.up
    create_table :abuses do |t|
      t.column :reason, :string
      t.column :created_at, :datetime
      t.column :abuseable_id, :integer
      t.column :abuseable_type, :string
    end
  end

  def self.down
    drop_table :abuses
  end
end
