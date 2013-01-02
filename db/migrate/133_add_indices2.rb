class AddIndices2 < ActiveRecord::Migration

  def self.up

    remove_index :answers, :question_id
    remove_index :answers, :best_answer
    add_index :answers, [:question_id,:best_answer]

    add_index :blog_posts, :created_at
    add_index :blog_posts, :blog_id
    add_index :blog_posts, :profile_id

    add_index :comments, :created_at
    remove_index :comments, :name => 'index_comments_on_author_id' # column renamed
    add_index :comments, :profile_id

    add_index :groups, :activity_status
    add_index :groups, :activity_points

    add_index :marketing_messages, :active
    add_index :marketing_messages, :is_default

    add_index :notes, :created_at

    # add_index :posts, :group_id
    # add_index :posts, :profile_id

    add_index :profiles, :is_admin
    add_index :profiles, :screen_name

    remove_index :question_profile_matches, :question_id  # has compound already

    remove_index :question_referrals, :name => 'index_question_referrals_on_profile_id' # column renamed
    add_index :question_referrals, [:owner_type, :owner_id]

    add_index :replies, :answer_id, :unique => true

    add_index :simple_captcha_data, :key, :unique => true

    add_index :top_terms, [:domain, :term], :unique => true

    remove_index :visitations, [:blog_id,:visitor_id]
    add_index :visitations, [:blog_id,:updated_at]

  end

  def self.down
    raise 'cannot go back!'
  end

end
