class AddGroupSlotsOverride < ActiveRecord::Migration
  def self.up
    add_column :profiles, :group_slots_override, :integer
  end

  def self.down
    remove_column :profiles, :group_slots_override
  end
end
