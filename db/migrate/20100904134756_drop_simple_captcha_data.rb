class DropSimpleCaptchaData < ActiveRecord::Migration
  def self.up
    drop_table :simple_captcha_data
  end

  def self.down
    puts "If you would like to go back to using simple captcha, please reinstall the plugin - MM2"
  end
end
