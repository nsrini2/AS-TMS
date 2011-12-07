class UserPasswordValidator

  def initialize
    @min_length = pwd_config('min_length')
    @max_length = pwd_config('max_length')
    @req_alpha = pwd_config_num('req_alpha')
    @req_numeric = pwd_config_num('req_numeric')
    @req_upper_lower = pwd_config('req_upper_lower')
    #@req_special = pwd_config_num('req_special') #!I undefined charset
    @max_sequential_chars = pwd_config_num('max_sequential_chars')
    @max_repeating_chars = pwd_config_num('max_repeating_chars')
    
    error_defs = []
    error_defs << [:min_length,"Password must be at least #{@min_length} characters."] if @min_length
    error_defs << [:max_length,"Password cannot be longer than #{@max_length} characters."] if @max_length
    error_defs << [:req_alpha,"Password must contain at least #{@req_alpha} letters."] if @req_alpha>1
    error_defs << [:req_numeric,"Password must contain at least #{@req_numeric} numbers."] if @req_numeric>1
    error_defs << [:upper_lower,"Password must contain both lower and upper case letters."] if @req_upper_lower
    error_defs << [:max_repeating,"Cannot have more than #{@max_repeating_chars} repeating characters. (ex: 1111)"] if @max_repeating_chars>1
    error_defs << [:max_sequential,"Cannot have more than #{@max_sequential_chars} sequential characters. (ex: abcd,1234)"] if @max_sequential_chars>1
    
    @verbal_rules = error_defs.collect { |(k,v)| v }
    @errors_map = error_defs.inject({})  { |h,(k,v)| h[k] = v; h }
    
  end

  def rules_list
    @verbal_rules
  end

  def validate(pwd)
    
    errors = []
    
    errors << @errors_map[:min_length] if @min_length && pwd.length<@min_length
    errors << @errors_map[:max_length] if @max_length && pwd.length>@max_length
    
    errors << @errors_map[:req_alpha] if @req_alpha && pwd.scan(/[a-zA-Z]/).length<@req_alpha
    errors << @errors_map[:req_numeric] if @req_numeric && pwd.scan(/[0-9]/).length<@req_numeric
    
    errors << @errors_map[:upper_lower] unless pwd=~/[A-Z]/ && pwd=~/[a-z]/ if @req_upper_lower

    errors << @errors_map[:max_repeating] if @max_repeating_chars>1 && pwd.match("(.)\\1{#{@max_repeating_chars}}")
    
    if pwd.length>1 && @max_sequential_chars>1
      counter = 0
      1.upto(pwd.length) do |p|
        counter = (pwd[p,1]=~/[B-Zb-z1-9]/ && pwd[p]-pwd[p-1]==1) ? counter+1 : 0
        if counter>=@max_sequential_chars
          errors << @errors_map[:max_sequential]
          break
        end
      end
    end

    errors
    
  end
  
  private
  
  def pwd_config(which)
    Config["user.pwd.#{which}"]
  end
  
  # return a config item as a number, where true=1 and nil=0
  @@pwd_config_num_defaults = { true => 1, nil => 0 }
  def pwd_config_num(which)
    v = pwd_config(which)
    @@pwd_config_num_defaults.fetch(v,v).to_i
  end
  
end