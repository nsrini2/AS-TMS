class ConvertPlansToPois < ActiveRecord::Migration

  def self.up

    rename_table :plan_elements, :pois
    rename_column :pois, :element_type, :poi_type
    
    drop_table :plans
    
    create_table :poi_lists do |t|
      t.datetime :created_at, :null => false
      t.string :name, :null => true
      t.integer :owner_id, :null => true
      t.integer :list_pois_count, :null => false, :default => 0
    end
    add_index :poi_lists, :created_at
    add_index :poi_lists, :name
    add_index :poi_lists, :owner_id
    
    create_table :list_pois do |t|
      t.string :owner_type, :null => false
      t.integer :owner_id, :null => false
      t.integer :poi_id, :null => false
      t.integer :position, :null => true
    end
    add_index :list_pois, [:owner_type,:owner_id]
    add_index :list_pois, :poi_id
    add_index :list_pois, :position
    
    execute "delete from activity_stream_events where klass='Plan'"
    execute "update activity_stream_events set klass='Poi' where klass='PlanElement'"
    
    execute "update attachments set owner_type='Poi' where owner_type='PlanElement'"
    
    execute "update poly_text_indices set owner_type='Poi' where owner_type='PlanElement'"
    execute "delete from poly_text_indices where owner_type='Plan'"
    
    execute "update comments set owner_type='Poi' where owner_type='PlanElement'"
    execute "delete from comments where owner_type='Plan'"
    
    execute "update abuses set abuseable_type='Poi' where abuseable_type='PlanElement'"
    execute "delete from abuses where abuseable_type='Plan'"
    
    execute "update audits set auditable_type='Poi' where auditable_type='PlanElement'"
    execute "delete from audits where auditable_type='Plan'"
    
    execute "update ratings set rated_type='Poi' where rated_type='PlanElement'"
    execute "delete from ratings where rated_type='Plan'"
    
    execute "delete from watch_events where action_item_type='Plan'"
    execute "update watch_events set action_item_type='Poi' where action_item_type='PlanElement'"
    
    execute "insert into list_pois (owner_type,owner_id,poi_id,position) select affiliate_type,affiliate_id,plan_element_id,position from affiliated_plan_elements where affiliate_type='Answer'"
    
    drop_table :affiliated_plan_elements

  end

  def self.down
    raise 'cant go back'
  end

end
