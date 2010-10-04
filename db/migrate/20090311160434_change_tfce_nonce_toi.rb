class ChangeTfceNonceToi < ActiveRecord::Migration

  def self.up
    remove_column :users, :tfce_req_nonce
    remove_column :users, :tfce_res_nonce
    add_column :users, :tfce_req_nonce, :integer
    add_column :users, :tfce_res_nonce, :integer
  end

  def self.down
    remove_column :users, :tfce_req_nonce
    remove_column :users, :tfce_res_nonce
    add_column :users, :tfce_req_nonce, :datetime
    add_column :users, :tfce_res_nonce, :datetime
  end

end
