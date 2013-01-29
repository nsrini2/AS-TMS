# Limit to a single DE account, sarah, kristin, mark, scott, marcelo

# DE Account #=> DE Admin
# Marcelo #=> Has Admin Link
# Sarah, Mark, Kristin, Scott #=> Link under content Admin


class DAndEController
  
end

# Skip before filters for DE content that's public
# Do some meta programming here...but this is the idea


# require_de_engine_file :controller, :root_controller
# class RootController
#   skip_before_filter :require_auth, :only => [:index]
# end

class ApplicationController
  def redirect_to_quick_registration
    puts "QUICK REG"
    puts logged_in?
    puts login_from_session
    puts current_user
    puts logged_in?
    unless logged_in?
      redirect_to(:controller => :account, :action => :quick_login) and return
    end
  end
end

publics = { :root => [:index],
            :offers => [:index, :show, :book],
            :filters => [:index, :sort],
            :sorts => [:index],
            :navigations => [:index, :page],
            :reviews => [:new, :up, :down, :create],
            :reports => [],
            :maps => [:index] }

publics.each_pair do |c, as|
  c_name = "#{c.to_s}_controller".camelize
  require_de_engine_file :controller, c_name.underscore
  
  c_name.constantize.__send__ :prepend_before_filter, :redirect_to_quick_registration, :except => as
  c_name.constantize.__send__ :skip_before_filter, :require_auth, :only => as
end

class FavoritesController
  # For now we are not doing any fancy session based folder stuff....
  prepend_before_filter :redirect_to_quick_registration, :except => [:index]
  skip_before_filter :require_auth, :only => [:index]
end


# Also there are certain things we let devise take care of
devises = { "Suppliers::OffersController" => [:new, :create] }

devises.each_pair do |c, as|
  c_name = "#{c.to_s}"
  
  puts c_name
  
  require_de_engine_file :controller, c_name.underscore
  
  c_name.constantize.__send__ :skip_before_filter, :require_auth, :only => as
end







# prepend_before_filter :open_deals_and_extras_content

# def open_deals_and_extras_content
#   puts self.controller_name
#   puts self.controller_path
#   puts self.action_name
#   if self.controller_name == "root" && self.action_name == "index"
#     puts "DO NOT REQUIRE AUTH"
#     self.skip_before_filter :require_auth
#     self.skip_before_filter :require_terms_acceptance
#     puts "TRYING TO SKIP FILTER"
#   end
# end