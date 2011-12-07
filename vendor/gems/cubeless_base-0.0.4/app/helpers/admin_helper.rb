module AdminHelper
  include MarketingMessagesHelper
  include AwardsHelper

  def render_additional_instructions_for(model)
    content_tag('p',h('Just copy and paste the code for your favorite web widget (usually a <script> tag). Width should be no greater than 250 pixels.')) if model=='widgets'
  end

  def render_reports_table(result)
    render :partial => 'table_template', :locals => {:result => result} if result
  end

  def link_to_remove_welcome_note
    link_button("Delete", "javascript:void(0);", :onclick => confirm_popup("Are you sure you want to delete this<br />welcome note? A welcome note will no<br /> longer be sent to new users.",
        :yes_function => remote_function(:url => stop_welcome_note_admin_path, :method => :delete)))
  end
end