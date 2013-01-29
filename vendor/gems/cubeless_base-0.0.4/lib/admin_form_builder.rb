class AdminFormBuilder < ActionView::Helpers::FormBuilder
  
  alias :super_label :label
  
  def label(*)
    dt super
  end
  
  def check_box_label(*args)
    check_box_dt super_label(args)
  end
  
  def text_field(*)
    dd super
  end
  
  def text_area(*)
    dd super
  end
  
  def check_box(*)
    check_box_dd super
  end 
  
  def select(*)
    dd super
  end
  
  
  def dt(html)
    "<dt>#{html}</dt>"
  end
  def check_box_dt(html)
    "<dt class=\"checkbox\">#{html}</dt>"
  end
  
  
  def dd(html)
    "<dd>#{html}</dd>"
  end
  def check_box_dd(html)
    "<dd class=\"checkbox\">#{html}</dd>"
  end
  
end