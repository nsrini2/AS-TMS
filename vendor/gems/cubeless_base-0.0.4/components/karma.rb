class Karma

  def initialize(points)
    @points = points
  end

  @@karma_max = 9999999
  @@karma_min = 0
  @@karma_level_names = {0=>'Newbie',1=>'Novice',2=>'Member',3=>'Guide',4=>'Advanced',5=>'Community Leader'}
  @@karma_level_ranges = [Range.new(@@karma_min,9),Range.new(10,19),Range.new(20,39),Range.new(40,79),Range.new(80,199),Range.new(200,@@karma_max)].freeze

  def points
    @points
  end

  def title
    self.class.title_for_level(level)
  end

  def self.title_for_level(level)
    @@karma_level_names[level]
  end

  def self.karma_level_ranges
    @@karma_level_ranges
  end

  def self.karma_max
    @@karma_max
  end

  def self.karma_min
    @@karma_min
  end

  def level
    Karma.level_for_points(@points)
  end

  def recognition_level
    level - 1
  end

  def summary_text
    "User rank: #{title} (#{points} karma points)"
  end

  def self.level_for_points(points)
    return 0 if points < 0
    @@karma_level_ranges.each_with_index { |r,i| return i if r.include?(points) }
  end

  @@points_required_for_photo = {1=>0,2=>10,3=>20,4=>40,5=>80}
  def self.points_required_for_nth_photo(n)
    @@points_required_for_photo.fetch(n)
  end

  def nth_photo_allowed?(n)
    required = @@points_required_for_photo[n]
    required and @points>=required
  end

end