class SemanticMatcher

  require 'set'
  require 'active_record'

  # for speed, we capture N(prefetch) matches, but only show N(max_assigned) at any given time
  @@question_match_max_assigned = 50
  @@question_match_max_prefetch = 65  # must be >= @@question_match_max_assigned

  @@regex_possesive_suffix = /\'s/
  @@regex_punctuation = /[^\w\s]/
  # this is the original punct set '!\'-"#$%&()*+,./:;<=>?@[\]^_`{|}~'
  #!H ended up modifying these for use with replacement with ' ' -- clean up desc later
  @@punct_chars = '!"#$%&()*+,./:;<=>?@[\]^_`{|}~'
  @@punct_chars_not_dblquote = '!#$%&()*+,./:;<=>?@[\]^_`{|}~'
  @@punct_collapse = '\''  #-
  #@@punct_to_spaces = '!,./;?'
  @@phrases_hash_cache = nil

  def self.default
    @@default_instance
  end

  def self.question_match_max_assigned
    @@question_match_max_assigned
  end

  def weak_term?(term)
    term.size<3 or @@stop_words.member?(term) or @@adverbs.member?(term) or @@adjectives.member?(term)
  end

  def get_terms_set(text,already_formatted=false)
    terms = Set.new
    if !already_formatted
      text = text.dup
      remove_punctuation_proper!(text)
      text.downcase!
    end
    yield_terms(text) { |term,term_words|
      terms << term unless weak_term?(term)
    }
    terms
  end

  def yield_terms(clean_text)
    split = clean_text.split(/\s+/)
    i=0
    while (i<split.size)
      phrase_size = phrase_length_at?(split,i)
      yield phrase_size>1 ? split[i,phrase_size].join(' ') : split[i], phrase_size
      i+=phrase_size
    end
  end

  def remove_terms(text,remove_terms)
    result = " #{text} "
    result.downcase!
    remove_terms.each do |word|
      result.gsub!(" #{word} ",' ?? ')
    end
    result
  end

  def phrase_length_at?(words_arr, index)
    options = SemanticMatcher.get_phrase_hash[words_arr[index]]
    options.each { |option|
      return option.size+1 if words_arr[index+1,option.size].eql?(option)
    } if options
    1
  end

  def SemanticMatcher.load_data_set(filename,set=Set.new)
    path = File.exists?("#{Rails.root}/data/#{filename}") ? "#{Rails.root}/data/#{filename}" : "#{CubelessBase::Engine.root}/data/#{filename}"
    File.new(path,'r').each_line do |word| set << word.strip end
    set
  end

  protected

  def db_prepare(sql)
    ActiveRecord::Base.connection.raw_connection.prepare(sql)
  end

  def db_raw
    ActiveRecord::Base.connection.raw_connection
  end

  def remove_punctuation_proper!(text,exclude_dblquote=false)
    #text.tr!(@@regex_possesive_suffix,'')
    text.tr!(@@punct_collapse,'')
    text.tr!(exclude_dblquote ? @@punct_chars_not_dblquote : @@punct_chars,' ')
    text
  end

  # these are only here to start, stolen from bambora.php
  # mysql will by default ignore words <4 characters
  # this is predominantly for visible keyword clouds and the user ignore_list at present
  @@stop_words = SemanticMatcher.load_data_set('stop_words.txt')
  @@suppress_display_terms = SemanticMatcher.load_data_set('suppress_display_terms.txt')
  @@adverbs = SemanticMatcher.load_data_set('wordnet_adverbs.txt')
  @@adjectives = SemanticMatcher.load_data_set('wordnet_adjectives.txt')

  def suppress_display_terms
    @@suppress_display_terms
  end

  def SemanticMatcher.suppress_display_terms
    @@suppress_display_terms
  end

  private

  def self.load_phrase_hash(filename,keyword_hash={})
    path = File.exists?("#{Rails.root}/data/#{filename}") ? "#{Rails.root}/data/#{filename}" : "#{CubelessBase::Engine.root}/data/#{filename}"
    
    # hash contains an array of array of words that follow
    File.new(path,'r').each_line do |phrase|
      phrase_words = phrase.split(/\s+/)
      key = phrase_words.shift
      arr = keyword_hash[key]
      keyword_hash.store(key,arr=[]) unless arr
      arr << phrase_words
    end
    keyword_hash
  end

  def self.get_phrase_hash
    return @@phrases_hash_cache if @@phrases_hash_cache
    @@phrases_hash_cache = {}
    SemanticMatcher.load_phrase_hash('wordnet_phrases.txt',@@phrases_hash_cache)
    SemanticMatcher.load_phrase_hash('custom_phrases.txt',@@phrases_hash_cache)
    puts "[semantic_matcher] Loaded #{@@phrases_hash_cache.size} phrase roots..."
    @@phrases_hash_cache
  end

  public

  # misleading name, now used for periodic sweeps
  def rematch_questions
    #!O :all expensive
    db_prepare('delete qpm from question_profile_matches qpm join questions q on q.id=qpm.question_id where q.open_until <= current_date() and q.directed_question=0').execute
    Question.open_questions.each do |q|
      puts "rematching question #{q.id}"
      match_question_to_profiles(q)
    end
  end

#  def match_groups
#    #GroupQuestionMatch.delete_all
#    if false
#      Question.open_questions.each do |q|
#        puts "matching question #{q.id} to groups"
#        match_question_to_groups(q)
#      end
#    else
#      Group.find(:all).each do |g|
#        puts "matching group #{g.id} to questions"
#        match_group_to_questions(g)
#      end
#    end
#  end

  # @@default_instance = Kernel.const_get(Config[:semantic_matcher]).new
  # @@default_instance = lambda { Object.const_get(Config[:semantic_matcher]).new }
  @@default_instance = Kernel.const_get(Config[:semantic_matcher]).new

end

