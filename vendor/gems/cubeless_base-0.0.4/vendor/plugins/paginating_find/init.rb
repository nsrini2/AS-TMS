require 'paginating_find'

ActiveRecord::Base.send(:include, PaginatingFind)
ActionView::Base.send(:include, PaginatingFind::Helpers)