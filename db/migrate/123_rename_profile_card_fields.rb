class RenameProfileCardFields < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :job_title, :profile_1
    rename_column :profiles, :tag_line, :profile_2
    rename_column :profiles, :location, :profile_3
    rename_column :profiles, :office, :profile_4
    rename_column :profiles, :phone_1, :profile_5
    rename_column :profiles, :phone_2, :profile_6
    rename_column :profiles, :organization, :profile_7
  end

  def self.down
    rename_column :profiles, :profile_1, :job_title
    rename_column :profiles, :profile_2, :tag_line
    rename_column :profiles, :profile_3, :location
    rename_column :profiles, :profile_4, :office
    rename_column :profiles, :profile_5, :phone_1
    rename_column :profiles, :profile_6, :phone_2
    rename_column :profiles, :profile_7, :organization
  end
end
