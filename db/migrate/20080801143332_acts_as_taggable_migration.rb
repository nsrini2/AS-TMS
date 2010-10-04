class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
    end

    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string

      t.column :created_at, :datetime
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]

    add_column :blog_posts, :cached_tag_list, :string
    add_index :blog_posts, :cached_tag_list
  end

  def self.down
    drop_table :taggings
    drop_table :tags
    remove_column :blog_posts, :cached_tag_list
    remove_index :blog_posts, :cached_tag_list
  end
end
