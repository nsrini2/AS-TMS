class AddingOurStoryAndTermsAndConditions < ActiveRecord::Migration
  def self.up
    create_table :about_us do |t|
      t.column :content, :text
    end

    create_table :terms_and_conditions do |t|
      t.column :content, :text
    end

    execute "insert into about_us (content) values('Content has not been set.')"
    execute "insert into terms_and_conditions (content) values('Content has not been set.')"
  end

  def self.down
    drop_table :about_us
    drop_table :terms_and_conditions
  end
end
