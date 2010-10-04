class AddPopularityToPlanElement < ActiveRecord::Migration
  
  def self.up
    add_column :plan_elements, :popularity, :float, :null => false, :default => 0.0
    execute("update plan_elements set popularity = (select count(1) from affiliated_plan_elements ate where ate.affiliate_type='Plan' and ate.plan_element_id=plan_elements.id)")
    add_index :plan_elements, :popularity
  end
  
  def self.down
    remove_column :plan_elements, :popularity
  end
  
end