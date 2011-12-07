class TopTerm < ActiveRecord::Base

  def self.terms_for_tag_cloud(domain='questions')
    find_by_sql(['select * from top_terms where domain=? order by term',domain.to_s])
  end

  def self.random_terms(domain, limit)
    find_by_sql(['select * from top_terms where domain=? order by rand() limit ?',domain.to_s, limit])
  end

end