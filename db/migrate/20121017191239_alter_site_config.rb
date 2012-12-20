class AlterSiteConfig < ActiveRecord::Migration
  def self.up
    change_table :site_configs do |t|
      t.change :disclaimer, :text
    end
    c = SiteConfig.first || SiteConfig.new
    c.disclaimer = "<br />\n*The information on this site is the intellectual property of the individual publishers or the opinions of community members.  The views expressed in these articles do not necessarily represent the views of Sabre Holdings, it's businesses, and its partners."
    c.save!        
  end

  def self.down
    change_table :site_configs do |t|
      t.change :disclaimer, :string
    end
  end
end


