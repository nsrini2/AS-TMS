module AgentStreamExtensions
  module String
     def to_month_year
       return "" unless self[/^[0-9]{6}$/]
       year =  self[/^[0-9]{4}/]
       month = Date::MONTHNAMES[(self[/[0-9]{2}$/]).to_i]
       "#{month} #{year}"
     end
  end
end