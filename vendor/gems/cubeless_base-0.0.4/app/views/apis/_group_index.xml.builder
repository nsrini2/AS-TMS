xml.document do
  xml.type('group')
  xml.id("group_#{group.id}")
  xml.description(group.description)
  xml.sponsorgroupinformation(group.tags)
  xml.url(group_url(group))
  xml.members do
    group.group_memberships.each do |membership|
      xml.member("profile_#{membership.profile_id}")
    end
  end
  xml.security do
    xml.groupid("group_#{group.id}") if group.private?
    xml.groupid("company_#{group.company_id}") if group.company_id && group.company_id > 0
  end
end