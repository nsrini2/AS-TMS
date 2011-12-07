module Utilities

  def beginning_of_month
    d = Date.today
    Date.new(d.year,d.month,1)
  end

  def string_to_date(string)
    return string unless string.is_a?(String)
    date_array = ParseDate.parsedate(string)
    Date.new(date_array[0], date_array[1], date_array[2]) rescue nil
  end

  def cleanse_word_list(word_list)
    clean_list = word_list.downcase # creates copy
    clean_list.strip!
    clean_list.gsub!(/\ +/,' ') # convert multi-space to single-space
    clean_list.gsub!(/\s*,\s*/,',') # strip spaces around delimiter
    clean_list = clean_list.split(',')
    clean_list = Set.new(clean_list)
    clean_list.delete('') # remove blank
    clean_list.to_a.join(',')
  end

  def find_by_type_and_id(type, id)
    Kernel.const_get(type).find(id) unless type.blank? || id.blank?
  end

  def action_post
      yield if request.post?
  end

  def default_paging(size=10)
    { :size => size, :current => params[:page] }
  end

  def self.included(base)
      base.send :helper_method, :default_paging
  end

end