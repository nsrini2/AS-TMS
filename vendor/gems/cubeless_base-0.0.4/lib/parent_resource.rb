module ParentResource
  #
  # Returns a hash of parent => id pairs extracted from the nested URL params
  #
  def parents_hash
    if @parents_hash.nil?
      @parents_hash = {}
      request.path_parameters.each do |key, value|
        next unless key.to_s =~ /^(.+)_id$/
        @parents_hash[$1] = value.to_i
      end
    end
    return @parents_hash
  end

  #
  # Similar to parents_hash but returns an array of hashes (first element is oldest parent, then later.. etc)
  # Each array element is a hash containing :name, :id
  #
  def parents_array
    if @parents_array.nil?
      hash = parents_hash
      @parents_array = []
      path_parts = request.path.split("/")
      path_parts.each do |part|
        next unless part.to_s =~ /^[a-z_]+$/
        singular = part.singularize or next
        next unless hash.has_key?(singular)
        @parents_array << {
          :name =>  singular,
          :id =>  hash[singular]
        }
      end
    end
    return @parents_array
  end

  #
  # Returns a parent object extracted from a nested URL
  # Takes an array index of depth (how far up parents to get) - defaults to -1 (most immediate)
  # Returns nil if no such parent exists
  def parent(level = -1)
    @parent ||= {}
    unless @parent.has_key?(level)
      if hash = parents_array[level]
        @parent[level] = hash[:name].classify.constantize.unscoped.find_by_id(hash[:id])
      else
        @parent[level] = nil
      end
    end
    instance_variable_set("@#{hash[:name]}", @parent[level]) if hash    
    return @parent[level]
  end

  #
  # Returns an array of parent objects
  #
  def parents
    if @parents.nil?
      @parents = []
      parents_array.each_index do |i|
        @parents << parent(i)
      end
    end
    return @parents
  end
end