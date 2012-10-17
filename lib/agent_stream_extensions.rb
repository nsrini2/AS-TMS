module AgentStreamExtensions
  module String
     def to_month_year
       return "" unless self[/^[0-9]{6}$/]
       year =  self[/^[0-9]{4}/]
       month = Date::MONTHNAMES[(self[/[0-9]{2}$/]).to_i]
       "#{month} #{year}"
     end
  end
  
  module Sample
    # SSJ 10-17-2012 this is a lot like try, but try was not working for me
    # also it will try a collection of methods
    # but does not take a block or additional parameters to pass to the method
    def sample(*keys)
      value = ""
      keys.each do |key|
        if self.respond_to?(key)
          value = self.send key
          break
        end
      end
      value
    end
  end
end