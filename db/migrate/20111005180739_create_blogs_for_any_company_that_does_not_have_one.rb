class TmpCompany < ActiveRecord::Base
  set_table_name :companies
end

class CreateBlogsForAnyCompanyThatDoesNotHaveOne < ActiveRecord::Migration
  def self.up
    TmpCompany.all.each do |c|
      unless Blog.find_by_owner_type_and_owner_id('Company', c.id)
        puts "Creating blog for company ##{c.id}"
        b = Blog.create(:owner_type => 'Company', :owner_id => c.id)
        puts "Created blog ##{b.id} for company ##{c.id}"
      end
    end
  end

  def self.down
  end
end
