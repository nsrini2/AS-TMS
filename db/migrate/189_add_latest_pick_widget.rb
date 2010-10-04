class AddLatestPickWidget < ActiveRecord::Migration

  def self.up
    execute("update profiles set widget_config=replace(widget_config,':seq_2=>[', ':seq_2=>[\"11\",') where widget_config is not null")
  end

  def self.down
    raise 'no no cant go back!'
  end

end