class AddRawXmlToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :raw_xml, :text
  end

  def self.down
    remove_column :offers, :raw_xml
  end
end
