class UpdateAbusesReasonColumnLimit < ActiveRecord::Migration
  def self.up
    change_column :abuses, :reason, :string, :limit => 4000
  end

  def self.down
    change_column :abuses, :reason, :string
  end
end