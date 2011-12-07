module ModelUtil

  def self.get_options(args)
    return args if args.is_a?(Hash)
    hash = args[-1]
    hash.is_a?(Hash) ? hash : nil
  end

  def self.get_options!(args)
    return args if args.is_a?(Hash)
    hash = args[-1]
    args << hash = Hash.new unless hash.is_a?(Hash)
    hash
  end

  def self.add_includes!(args, *includes)
    (get_options!(args)[:include] ||= []).concat(includes)
  end

  def self.add_selects!(args, select_arg)
    hash = get_options!(args)
    select_args = hash[:select]
    return select_args << ', ' << select_arg if select_args
    hash[:select] = select_arg
  end

  # conditions can be a string or prepared array
  def self.add_conditions!(args, conditions)
    hash = get_options!(args)
    hash_conditions = hash[:conditions]
    return hash[:conditions] = conditions unless hash_conditions
    if hash_conditions.is_a?(String)
      return hash[:conditions] = and_conditions(hash_conditions,conditions) if conditions.is_a?(String)
      hash_conditions = hash[:conditions] = [hash_conditions]
    end
    return hash_conditions[0] = and_conditions(hash_conditions[0],conditions) if conditions.is_a?(String)
    hash_conditions[0] = and_conditions(hash_conditions[0],conditions[0])
    hash_conditions.concat(conditions[1..-1])
  end

  def self.add_joins!(args,join)
    hash = get_options!(args)
    joins = hash[:joins]
    if joins
      joins << ' ' << join
    else
      hash[:joins] = join
    end
  end


  def self.nil_data!(model,column_names)
    column_names.each do |col|
      model[col] = nil
    end
    model.save_with_validation(false)
  end

  private
  def self.and_conditions(c1,c2)
    "(#{c1}) and (#{c2})"
  end

end