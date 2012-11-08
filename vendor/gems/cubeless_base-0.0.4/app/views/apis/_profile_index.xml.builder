xml.document do
  xml.type('userprofile')
  xml.id("userprofile_#{profile.id}")
  xml.description('description')
  xml.fullname(profile.screen_name)
  xml.company(profile.company ? profile.company.name : "")
  xml.url(profile_url(profile))
  xml.specialties do
    (1..12).each do |i|
      value = profile.send "profile_#{i}"
      xml.specialty(value) if value && !value.blank?
    end
  end
  xml.profileinformation do
    (1..12).each do |i|
      value = profile.send "question_#{i}"
      xml.profileinfoblock(value) if value && !value.blank?
    end
  end
  xml.security do
    profile.group_memberships.each do |group|
      xml.groupid("group_#{group.group_id}")
    end
    xml.groupid("company_#{profile.company_id}") if profile.company_id
  end
end