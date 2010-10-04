class CreateCustomReports < ActiveRecord::Migration
  def self.up
    create_table :custom_reports do |t|
      t.string :name
      t.text :form

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_reports
  end
end
