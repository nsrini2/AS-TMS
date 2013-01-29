class AddPoiCountToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :answers_poi_count, :integer, :null => false, :default => 0
    execute "update questions q set q.answers_poi_count=(select count(1) from answers a join list_pois lp on a.id=lp.owner_id and lp.owner_type='Answer' where a.question_id=q.id)"
  end

  def self.down
    remove_column :questions, :answers_poi_count
  end
end
