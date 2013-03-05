class CreateShowcaseTexts < ActiveRecord::Migration
  def self.up
    create_table :showcase_texts do |t|
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :showcase_texts
  end
end
