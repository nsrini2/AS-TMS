class UserImport
  require 'csv'

  def initialize(file_name="user_import.txt", dry=false)
    @dry = dry
    @valid_cols = UserImport.valid_import_columns
    @log_file = File.new("#{RAILS_ROOT}/log/user_import_logger.log", "a+")
    @import_file = CSV.open(file_name, 'r', '|')
  end

  def self.prepare(file_name="user_import.csv")
    row_num = 0
    data = []
    CSV.open(file_name, 'r', ',') do |row|
      row_num += 1
      rowData = row.join("|")
      data << rowData
    end
    new_file = File.new("#{RAILS_ROOT}/log/user_import.txt", "w")
    data.each do |d|
      new_file.puts d
    end
    new_file.close
  end

  def self.run(options={})
    UserImport.new(options[:file_name], options[:dry]).run_import
  end

  def self.valid_import_columns
    @@valid_columns ||= Profile.get_questions_from_config.keys + ["password", "first_name", "last_name", "knowledge", "karma_points", "screen_name", "login"]
  end

  def run_import
    @log_file.puts "User Import started: #{Time.now}\n"
    successful, failed = 0,0
    begin
      extract_column_mappings
      @import_file.each_with_index do |row, row_num|
        next if comment_row?(row)
        u,p = build_user_and_profile(row)
        if (p.valid? & u.valid?)
          u.save && p.save unless @dry
          successful += 1
          print(".")
        else
          failed += 1
          print("E")
          @log_file.puts "Row: #{row_num + 2}"
          @log_file.puts "\t\t" + u.errors.full_messages.join("\n\t")
          @log_file.puts "\t\t" + p.errors.full_messages.join("\n\t")
        end
      end
    rescue Exception => e
      puts e
      #stop processing
    end
    puts "\nSuccessful: #{successful}"
    puts "Failed: #{failed}"
    @log_file.puts "User Import completed: #{Time.now}"
    @log_file.close
  end
  private

  def extract_column_mappings
    @imported_columns = @import_file.shift.collect{|x| x.strip}
    @imported_columns.each do |mapping|
      unless @valid_cols.include?(mapping)
        print("E")
        msg = "Column #{mapping} is not a valid import column. The valid import columns are #{@valid_cols.join(',')}"
        @log_file.puts msg
        raise Exception.new(msg)
      end
    end
  end

  def comment_row?(row)
    row[0].index(/^#/)
  end

  def build_user_and_profile(row)
    u = User.new
    p = Profile.new
    row.each_with_index do |col, i|
      next if col.blank?
      col_data = col.strip
      u.send("#{@imported_columns[i]}=", col_data) if u.respond_to?("#{@imported_columns[i]}=")
      p.send("#{@imported_columns[i]}=", col_data) if p.respond_to?("#{@imported_columns[i]}=")
    end
    u.password_confirmation = u.password
    p.status = 2
    u.profile = p
    [u,p]
  end
end