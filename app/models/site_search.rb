# to update index:
# rake environment tire:import CLASS=Article FORCE=true
class SiteSearch
  extend LocalTire::ActiveModel::Extensions
  per_page 10
  @default_search_indexes = ['profiles', 'groups', 'blog_posts', 'questions', 'chats']

  
  def self.search(params)
    current_page = get_page(params[:page])
    query_string = params[:query] if params.member?(:query)
    if params.member?(:scope) && params[:scope] != 'all'
      search_indexes params[:scope] 
    else
      search_indexes *@default_search_indexes
    end
    
    results = perform_query(query_string, current_page).results
    results.extend Tire::Results::Pagination
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error "[Tire::Search::Search] Unable to connect to ElasticSearch database!"
      puts e
      generate_mock_results
    rescue Exception => e
      Rails.logger.error e
      puts e
      generate_mock_results
  end

private
  
  def self.perform_query(query_string, current_page)
    Tire.search get_search_indexes do
      if query_string
        query do
          string query_string, 
          :default_operator => "AND", 
          :fields => [:screen_name, :search_content, :description, :title, :tags, :comments, :question, :answers, :topics, :posts]
        end
      end
      # SSJ Use filters for requirments that don't affect the relevance score
      filter :bool, :must_not => { :term => {:private, true}}
      filter :bool, :must_not => { :term => {:company, true}}
      from (current_page-1) * (SiteSearch::get_per_page)
      size SiteSearch::get_per_page
      # raise to_json
    end
  end
end  