xml.document do
  xml.type('faq')
  xml.id("faq_#{question.id}")
  xml.question(question.question)
  xml.author(question.profile.screen_name)


  xml.answers do 
    question.answers.each do |answer|
      xml.text(answer.answer)
      xml.rate(answer.net_helpful)
      xml.bestanswer(answer.best_answer)
    end
  end
  xml.security do
    xml.groupid("company_#{question.company_id}") if question.company_id && question.company_id > 0
  end
end