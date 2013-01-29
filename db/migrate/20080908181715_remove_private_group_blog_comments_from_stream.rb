class RemovePrivateGroupBlogCommentsFromStream < ActiveRecord::Migration
  def self.up
    execute("delete e from activity_stream_events e join comments c on e.klass_id = c.id join blog_posts p on c.owner_id = p.id join blogs b on p.blog_id = b.id join groups g on b.owner_id = g.id where e.klass = 'Comment' and c.owner_type = 'BlogPost' and g.group_type = '2'")
  end

  def self.down
  end
end
