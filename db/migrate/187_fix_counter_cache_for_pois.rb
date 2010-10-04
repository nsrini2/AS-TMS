class FixCounterCacheForPois < ActiveRecord::Migration
  def self.up
    [:answers, :profiles].each do |tab|
      rename_column tab, :affiliated_plan_elements_count, :list_pois_count
      change_column tab, :list_pois_count, :integer, :null => false, :default => 0
    end
  end

  def self.down
    [:answers, :profiles].each do |tab|
      rename_column tab, :list_pois_count, :affiliated_plan_elements_count
      change_column tab, :affiliated_plan_elements_count, :integer, :null => false, :default => 0
    end
  end
end
