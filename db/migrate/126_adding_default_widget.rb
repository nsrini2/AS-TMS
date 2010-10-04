class AddingDefaultWidget < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.column :content, :text
    end

    execute "insert into widgets (content) values('Content has not been set.')"
  end

  def self.down
    drop_table :widgets
  end
end
