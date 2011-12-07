module UserReports
  
  module ClassMethods
    def total_requests(dates)
      find(:all, :conditions => "created_at BETWEEN #{dates}")
    end
  
    def total_unique_requests(dates)
      # group does not work :( need to fix Patch
      # find(:all, :conditions => "created_at BETWEEN #{dates}", :group => 'email')
      query = "SELECT id, login, email, temp_crypted_password 
              FROM users 
              WHERE created_at BETWEEN #{dates} 
              GROUP BY email"
      find_by_sql(query)
    end
  
    def unique_requests_not_active(dates)
      # group does not work :( need to fix Patch
      query = "SELECT count(id) as my_count, id, login, email, GROUP_CONCAT(IFNULL(crypted_password, 'NULL')) as my_value 
               FROM users
               WHERE created_at BETWEEN #{dates}
               GROUP BY email
               HAVING my_value NOT REGEXP '[0-9]+'"
      find_by_sql(query)
    end
  
    def total_users_approved(dates)
      find(:all, :conditions => "created_at BETWEEN #{dates} AND temp_crypted_password IS NOT NULL")         
    end
  
    def unique_users_approved(dates)
      # group does not work :( need to fix Patch
      query = "SELECT count(id) as my_count, id, login, email, temp_crypted_password, GROUP_CONCAT(IFNULL(crypted_password, 'NULL')) as my_value 
               FROM users
               WHERE created_at BETWEEN #{dates}
               AND temp_crypted_password IS NOT NULL
               GROUP BY email"
      find_by_sql(query)         
    end
  
    def unique_approved_active(dates)
      # group does not work :( need to fix Patch
      query = "SELECT count(id) as my_count, id, login, email, temp_crypted_password, GROUP_CONCAT(IFNULL(crypted_password, 'NULL')) as my_value 
              FROM users
              WHERE created_at BETWEEN #{dates}
              AND temp_crypted_password IS NOT NULL
              GROUP BY email
              HAVING my_value REGEXP '[0-9]+'"
      find_by_sql(query)        
    end
  
    def unique_approved_not_active(dates)
      # group does not work :( need to fix Patch
      query = "SELECT count(id) as my_count, id, login, email, temp_crypted_password, GROUP_CONCAT(IFNULL(crypted_password, 'NULL')) as my_value 
              FROM users
              WHERE created_at BETWEEN #{dates}
              AND temp_crypted_password IS NOT NULL
              GROUP BY email
              HAVING my_value NOT REGEXP '[0-9]+'"
      find_by_sql(query)        
    end
  
  end
end