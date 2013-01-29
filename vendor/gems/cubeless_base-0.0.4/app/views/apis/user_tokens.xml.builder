xml.usersecurity do
  # 0 means everything is ok
  xml.status('0')
  xml.securitytokens do
    @groups.each do |group|
      xml.token("group_#{group}")
    end
    xml.token("company_#{@company}") if @company
  end
end