class MakeBusinessCardFieldGeneric < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :work_phone, :phone_1
    rename_column :profiles, :cell_phone, :phone_2
    rename_column :profiles, :cube_number, :office
  end

  def self.down
    rename_column :profiles, :phone_1, :work_phone
    rename_column :profiles, :phone_2, :cell_phone
    rename_column :profiles, :office, :cube_number
  end
end
