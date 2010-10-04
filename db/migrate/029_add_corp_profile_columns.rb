class AddCorpProfileColumns < ActiveRecord::Migration
  def self.up
    add_column :profiles, :job_title, :string
    add_column :profiles, :organization, :string
    add_column :profiles, :location, :string
    add_column :profiles, :work_phone, :string
    add_column :profiles, :cell_phone, :string
    add_column :profiles, :cube_number, :string
  end
  
  def self.down
    remove_column :profiles, :job_title
    remove_column :profiles, :organization
    remove_column :profiles, :location
    remove_column :profiles, :work_phone
    remove_column :profiles, :cell_phone
    remove_column :profiles, :cube_number
  end
end
