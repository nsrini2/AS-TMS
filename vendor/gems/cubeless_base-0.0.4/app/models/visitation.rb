class Visitation < ActiveRecord::Base

  belongs_to :visitor, :foreign_key => 'profile_id', :class_name => 'Profile'
  belongs_to :owner, :polymorphic => true

  def self.add_visitor_for(model,profile)
    if model.visitors.include?(profile)
      visit = Visitation.find_by_owner_type_and_owner_id_and_profile_id(model.class.name,model.id,profile.id)
      Visitation.update_all("updated_at=now()","id=#{visit.id}") if visit.updated_at < Time.now-2.minutes
    else
      model.visitors << profile
    end
  end

  def self.remove_additional!(type,max)
    db = ActiveRecord::Base.connection.raw_connection
    db.query("select owner_id from visitations where owner_type='#{type}' group by owner_id having count(1)>#{max}").each do |rs|
      owner_id = rs[0]
      min_updated = db.query("select min(updated_at) from (select updated_at from visitations where owner_type='#{type}' and owner_id=#{owner_id} order by updated_at desc limit #{max}) as x").first[0]
      db.query("delete from visitations where updated_at<'#{min_updated}' and owner_type='#{type}' and owner_id=#{owner_id}")
    end
  end

end