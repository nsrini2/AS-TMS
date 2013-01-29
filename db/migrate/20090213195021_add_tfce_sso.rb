class AddTfceSso < ActiveRecord::Migration
  
  def self.up
    add_column :users, :tfce_req_nonce, :datetime
    add_column :users, :tfce_res_nonce, :datetime
  end

  def self.down
    remove_column :users, :tfce_req_nonce
    remove_column :users, :tfce_res_nonce
  end
  
end
