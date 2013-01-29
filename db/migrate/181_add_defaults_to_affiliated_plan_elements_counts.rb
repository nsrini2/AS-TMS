class AddDefaultsToAffiliatedPlanElementsCounts < ActiveRecord::Migration

  def self.up
    execute("update answers set affiliated_plan_elements_count=0 where affiliated_plan_elements_count is null")
    execute("update plans set affiliated_plan_elements_count=0 where affiliated_plan_elements_count is null")
    execute("update profiles set affiliated_plan_elements_count=0 where affiliated_plan_elements_count is null")

    change_column :answers, :affiliated_plan_elements_count, :integer, :null => false, :default => 0
    change_column :plans, :affiliated_plan_elements_count, :integer, :null => false, :default => 0
    change_column :profiles, :affiliated_plan_elements_count, :integer, :null => false, :default => 0
  end

  def self.down
  end

end