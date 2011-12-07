module EmailHelper
  
  def link_from_email(text, path, options={})
    options[:style] = options[:style].to_s + "color: #008c99;"
     
    link_to(text, path, options)
  end

end