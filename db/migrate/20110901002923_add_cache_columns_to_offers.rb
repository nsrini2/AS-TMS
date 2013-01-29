class AddCacheColumnsToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :cached_supplier_name, :string
    add_column :offers, :cached_reviews_count, :integer
    add_column :offers, :cached_positive_review_percentage, :float
  end

  def self.down
    remove_column :offers, :cached_supplier_name
    remove_column :offers, :cached_reviews_count
    remove_column :offers, :cached_positive_review_percentage
  end
end
