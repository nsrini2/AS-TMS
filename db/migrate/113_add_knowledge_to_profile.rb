class AddKnowledgeToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :knowledge, :string
  end

  def self.down
    remove_column :profiles, :knowledge
  end
end
