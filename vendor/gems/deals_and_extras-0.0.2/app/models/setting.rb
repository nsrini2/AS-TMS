# This class isn't meant to be instantiated

class Setting < ActiveRecord::Base

  def self.method_missing(sym, *args, &block)

    if self.respond_to?(sym)
      super sym, *args, &block
    else
      method = sym.to_s
      name = method.gsub('=', '')
      if method.include?('=')
        self.set_setting(name, args.first)
      else
        self.get_setting(name)
      end
      
    end

  end

  def self.set_setting(name, setting)
    s = self.find_or_create_by_name(name)
    s.update_attribute(:setting, setting)
  end
  
  def self.get_setting(name)
    setting = self.find_by_name(name)
    setting.setting rescue nil
  end

end