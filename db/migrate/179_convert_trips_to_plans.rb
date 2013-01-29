class ConvertTripsToPlans < ActiveRecord::Migration

  def self.up

    remove_index :trips, :trip_type
    rename_table :trips, :plans
    rename_column :plans, :trip_type, :plan_type
    rename_column :plans, :affiliated_trip_elements_count, :affiliated_plan_elements_count
    add_index :plans, :plan_type

    rename_table :trip_elements, :plan_elements

    remove_index :affiliated_trip_elements, :name => 'at_ai_tei'
    remove_index :affiliated_trip_elements, :name => 'tei_at'
    rename_table :affiliated_trip_elements, :affiliated_plan_elements
    rename_column :affiliated_plan_elements, :trip_element_id, :plan_element_id

    add_index :affiliated_plan_elements, [:affiliate_type,:affiliate_id,:plan_element_id], :name => 'at_ai_pei'
    add_index :affiliated_plan_elements, [:plan_element_id,:affiliate_type], :name => 'pei_at'

    rename_column :answers, :affiliated_trip_elements_count, :affiliated_plan_elements_count
    rename_column :profiles, :affiliated_trip_elements_count, :affiliated_plan_elements_count

    execute "update activity_stream_events set klass='Plan' where klass='Trip'"
    execute "update activity_stream_events set klass='PlanElement' where klass='TripElement'"

    execute "update affiliated_plan_elements set affiliate_type='Plan' where affiliate_type='Trip'"

    execute "update attachments set owner_type='PlanElement' where owner_type='TripElement'"

    # execute "update poly_text_indices set owner_type='PlanElement' where owner_type='TripElement'"
    # execute "update poly_text_indices set owner_type='Plan' where owner_type='Trip'"

    execute "update comments set owner_type='PlanElement' where owner_type='TripElement'"
    execute "update comments set owner_type='Plan' where owner_type='Trip'"

    execute "update abuses set abuseable_type='PlanElement' where abuseable_type='TripElement'"
    execute "update abuses set abuseable_type='Plan' where abuseable_type='Trip'"

    execute "update audits set auditable_type='PlanElement' where auditable_type='TripElement'"
    execute "update audits set auditable_type='Plan' where auditable_type='Trip'"

    execute "update ratings set rated_type='PlanElement' where rated_type='TripElement'"
    execute "update ratings set rated_type='Plan' where rated_type='Trip'"

    execute "update watch_events set action_item_type='Plan' where action_item_type='Trip'"
    execute "update watch_events set action_item_type='PlanElement' where action_item_type='TripElement'"

  end

  def self.down
    raise 'cant go back'
  end

end