class ModifyVisitationForPoly < ActiveRecord::Migration
  def self.up
    remove_index :visitations, [:blog_id,:updated_at]

    rename_column :visitations, :visitor_id, :profile_id
    rename_column :visitations, :blog_id, :owner_id
    add_column :visitations, :owner_type, :string, :null => false

    execute "update visitations v left join blogs b on b.id=v.owner_id set v.owner_type=b.owner_type, v.owner_id=b.owner_id"

    add_index :visitations, [:owner_type,:owner_id,:updated_at]
  end

  def self.down
    remove_index :visitations, [:owner_type,:owner_id,:updated_at]

    execute "update visitations v left join blogs b on b.owner_id=v.owner_id set v.owner_id=b.id"

    rename_column :visitations, :profile_id, :visitor_id
    rename_column :visitations, :owner_id, :blog_id
    remove_column :visitations, :owner_type

    add_index :visitations, [:blog_id,:updated_at]
  end
end
