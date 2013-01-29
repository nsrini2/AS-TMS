class RemovePoiImages < ActiveRecord::Migration
  def self.up
	execute "update attachments set owner_id=-1, type=null where type in ('TripElementImage','PoiImage','PlanElementImage')"
    Attachment.destroy_all("owner_id=-1 and parent_id is not null")
    Attachment.destroy_all("owner_id=-1 and parent_id is null")
  end

  def self.down
    #not reversable
  end
end
