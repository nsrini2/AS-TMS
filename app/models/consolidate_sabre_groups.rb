class ConsolidateSabreGroups
  def initialize(original_group_id, new_group_id)
    @original_group_id = original_group_id
    @new_group_id = new_group_id
  end
  def update_notes
    sql = <<-EOS
      UPDATE 
        notes 
      SET 
        receiver_id=#{@new_group_id} 
      WHERE 
        receiver_id=#{@original_group_id}
        AND
        receiver_type='Group'
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_group_memberships
    sql = <<-EOS
      UPDATE IGNORE
        group_memberships 
      SET 
        group_id=#{@new_group_id} 
      WHERE 
        group_id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
    sql = <<-EOS
      DELETE FROM
        group_memberships 
      WHERE 
        group_id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_question_referrals
    sql = <<-EOS
      UPDATE 
        question_referrals 
      SET 
        owner_id=#{@new_group_id} 
      WHERE 
        owner_id=#{@original_group_id}
        AND
        owner_type='Group'
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_group_invitations
    sql = <<-EOS
      UPDATE
        group_invitations 
      SET 
        group_id=#{@new_group_id} 
      WHERE 
        group_id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_group_posts
    sql = <<-EOS
      UPDATE
        group_posts 
      SET 
        group_id=#{@new_group_id} 
      WHERE 
        group_id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_blog_posts
    new_group_blog_id = Group.unscoped.find(@new_group_id).blog.id
    original_group_blog_id = Group.unscoped.find(@original_group_id).blog.id
    sql = <<-EOS
      UPDATE
        blog_posts 
      SET 
        blog_id=#{new_group_blog_id} 
      WHERE 
        blog_id=#{original_group_blog_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
    sql = <<-EOS
      DELETE FROM
        blogs 
      WHERE 
        id=#{original_group_blog_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_watch_events
    sql = <<-EOS
      UPDATE 
        watch_events 
      SET 
        watchable_id=#{@new_group_id} 
      WHERE 
        watchable_id=#{@original_group_id}
        AND
        watchable_type='Group'
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def update_gallery_photos
    sql = <<-EOS
      UPDATE
        gallery_photos 
      SET 
        group_id=#{@new_group_id} 
      WHERE 
        group_id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def soft_delete_group
    sql = <<-EOS
      UPDATE
        groups 
      SET 
        active=0 
      WHERE 
        id=#{@original_group_id}
    EOS
    # select with ActiveRecord
    ActiveRecord::Base.connection.execute(sql)
  end
  def self.consolidate!
    groups_to_change = [[140,176],[171,176],[24,177],[25,177],[79,177],[84,177],[99,177]]
    groups_to_change.each do |tuple|
      consolidator = ConsolidateSabreGroups.new(*tuple)
      update_methods = ConsolidateSabreGroups.instance_methods(false).select { |m| m[/^update_.*/] }
      update_methods.each do |method|
        puts "Running #{method} for #{tuple[0]}"
        consolidator.send method
      end
      consolidator.soft_delete_group
    end
  end
end
