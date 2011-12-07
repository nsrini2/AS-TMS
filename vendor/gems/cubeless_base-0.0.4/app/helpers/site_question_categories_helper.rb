module SiteQuestionCategoriesHelper
  
  def delete_status(site_question_category)
    if site_question_category.has_questions?
      "<i>Questions present. Cannot delete.</i>"
    else
      link_to 'Delete', 
              site_admin_site_question_category_path(site_question_category), 
              :confirm => 'Are you sure?', :method => :delete
    end
  end
  
end
