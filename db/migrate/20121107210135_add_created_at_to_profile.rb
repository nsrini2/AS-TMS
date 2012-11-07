class AddCreatedAtToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :created_at, :datetime
    
    # set default values to matching users
    sql = <<-EOS
      UPDATE profiles, users 
      SET profiles.created_at = users.created_at
      WHERE profiles.user_id = users.id
    EOS
    ActiveRecord::Base.connection.execute(sql)
    
    # set default values for any profiles that lack users
    sql = <<-EOS
      UPDATE profiles
      SET profiles.created_at = profiles.updated_at
      WHERE profiles.created_at IS NULL
    EOS
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
    remove_column :profiles, :created_at
  end
end
