require 'set'
require 'benchmark'
require 'fastercsv'

class UserSync

  ProfileColumns = Set.new
  UserColumns = Set.new

  # abstract class
  class DataSource

    attr_reader :line_no, :columns_set
    def initialize(reader)
      @reader = reader

      # some columns we only want to set when creating a record...
      # to do this, we support annotations on the column description in the format of column_name[a,b,c]
      # current, no attributes means all enabled
      # n = new, u = update
      @columns = reader.columns.dup.compact
      @column_attrs = {}
      @columns.map! do |c|
        c, attrs = c.match(/^(.+?)(?:\[(.*)\])?$/).captures
        @column_attrs[c] = Set.new(attrs.split(',')) if attrs
        c
      end
      @columns_set = Set.new(@columns).freeze
      @row_name_values = {} # next_row value holder
    end

    def column_has_attr(col,attr)
      attrs = @column_attrs[col]
      attrs.nil? || attrs.member?(attr)
    end

    def next_row
      return nil unless row = @reader.next_row
      @columns.each_with_index { |name,i| @row_name_values[name] = row[i] }
      @row_name_values
    end

    def inspect_row
      "row:#{@reader.row_num} data:#{@row_name_values.inspect}"
    end

  end

  class CSVReader
    attr_reader :columns, :row_num
    def initialize(io)
      @reader = FCSV.new(io)
      @columns = @reader.shift
      @row_num = 1
      @row = nil
    end
    def next_row
      row = @reader.shift
      return nil if row.nil? || row.empty?
      @row_num += 1
      row
    end
  end

  class ProfileHandler

    @@status_from_string = { 'active' => 1, 'inactive' => 0, 'delete' => -1, 'activate_on_login' => 2 }
    @@status_for_id = @@status_from_string.inject({}) { |h,kv| h[kv[1]] = kv[0]; h }

    attr_accessor :id, :profile, :sync, :visited
    def initialize(sync,profile=Profile.new(:user => User.new))
      @sync = sync
      @profile = profile
      @visited = false
      @write_attribute = profile.new_record? ? 'n' : 'u'
      profile.add_roles Role::DirectMember
    end
    def update_from_row(ds,row)
      sync.fail_if_excluded!(self)
      row.each_pair do |k,v|
        next unless sync.valid_columns_set.member?(k)
        next unless ds.column_has_attr(k,@write_attribute)
        self[k] = v
      end
      profile.user.password = row['password'] unless row['password'].blank?
      profile.screen_name = "#{profile.first_name} #{profile.last_name}" if profile.screen_name.blank?
      if profile.status==-1 # mark active if queued for delete(-1), leave disabled(0) alone
        profile.status = 1
        profile.visible = true unless row['visible']
      end
    end
    def [](k)
      return @@status_for_id[profile[k]] if k=='status'
      if ProfileColumns.member?(k)
        return profile[k] || profile.__send__(k) 
      end
      return profile.user[k] if UserColumns.member?(k)
      #!I fail
    end
    def []=(k,v)
      v = @@status_from_string[v] if k=='status'
      profile[k]=v if ProfileColumns.member?(k)
      profile.user[k]=v if UserColumns.member?(k)
      #!I fail
    end
    def save!
      @visited=true
      return unless profile.user.modified? or profile.modified?
      new_record = profile.new_record?
      if sync.commit_changes?
        Profile.transaction do
          profile.user.save!
          profile.save!
        end
      else
        raise(RecordNotSaved) unless profile.user.valid? && profile.valid?
      end
      if new_record
        sync.response.inc :added
        sync.response.info "#{sync.identify(self)} added\n" +
        profile.user.modified_attributes_values(profile.modified_attributes_values).inspect
      else
        sync.response.inc :updated
        sync.response.info "#{sync.identify(self)} updated\n" +
        profile.user.modified_attributes_changes(profile.modified_attributes_changes).inspect
      end
    end
  end

  class Response

    attr_reader :io, :counts
    attr_accessor :ds
    def initialize(io=$stdout)
      @io = io
      @io_std = io==$stdout
      @counts = Hash.new { |h,k| h[k]=0 }
    end

    def capture(&block)
      begin
        yield
      rescue Exception
        fail($!,false)
      end
      self
    end

    def inc(which)
      counts[which] += 1
    end

    def fail(msg,raise=true)
      raise Exception.new(msg) if raise
      self.inc(:failures)
      @io.puts "\nfail: #{msg}"
      @io.puts ds.inspect_row if ds
    end

    def warn(msg,ds_inspect=false)
      puts "\nwarning: #{msg}"
      self.inc(:warnings)
      @io.puts "\nwarning: #{msg}"
      @io.puts ds.inspect_row if ds_inspect && ds
    end

    def info(msg)
      puts("\ninfo: #{msg}") unless @io_std
      @io.puts("\ninfo: #{msg}")
    end
  end

  public
  attr_reader :valid_columns_set, :response
  def initialize(options={})

    @options = {:commit => false}.merge(options)
    @response = Response.new(options.fetch(:io,$stdout))

    @response.info("*** TEST RUN ***") unless commit_changes?

    #!H lazy load
    ProfileColumns.merge(Profile.column_names) if ProfileColumns.empty?
    UserColumns.merge(User.column_names) if UserColumns.empty?
    
    # # MM2: Add primary_photo_present? to ProfileColumns
    ProfileColumns.merge(["primary_photo_present?"]) 

    # MM2: Add travel_email_status to ProfileColumns
    ProfileColumns.merge(["travel_email_status"]) 

    # MM2: Add profile_completion to ProfileColumns
    ProfileColumns.merge(["completion_percentage"])
    
    # MM2: Add company_id to ProfileColumns
    ProfileColumns.merge(["company_id"])

    @valid_columns_set = Set.new(Profile.get_questions_from_config.keys + ['password', 'first_name', 'last_name', 'alt_first_name', 'alt_last_name', 'knowledge', 'karma_points', 'screen_name', 'login', 'sso_id', 'old_sso_id', 'old_login', 'visible', 'status','email', 'last_login_date', 'primary_photo_present?', 'travel_email_status', "completion_percentage", "company_id"])

    @profiles_by_eid = {}
    @profiles_by_login = {}
    puts Benchmark.measure {
      puts "Caching profile data..."
      @profiles = Profile.base_find(:all,:include => :user, :conditions => 'profiles.status>=-1').map! do |p|
        u,p = p.user, ProfileHandler.new(self,p)
        @profiles_by_eid[u.sso_id] = p if u.sso_id
        @profiles_by_login[u.login] = p if u.login
        p
      end
      puts "#{@profiles.size} profiles loaded."
    }

  end

  def commit_changes?
    @options[:commit]
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end

  def do_action(ds,action)
    case action
      when 'delete' then delete_users(ds)
      when 'add' then add_users(ds)
      when 'update' then update_users(ds)
      when 'sync' then sync_users(ds)
      else @response.fail("Unknown action #{action}")
    end
  end

  def delete_users(ds)
    ds = init_ds(ds)
    ds_each_row(ds) do |row|
      @response.capture do
        p = find_profile_for_row(row)
        begin @response.warn("user doesn't exist #{identify(row)}"); next; end unless p
        deactivate_profile(p)
      end
    end
  end

  def add_users(ds)
    ds = init_ds(ds)
    ds_each_row(ds) do |row|
      @response.capture do
        p = find_profile_for_row(row)
        begin @response.warn("user already exists #{identify(p)}"); next; end if p
        p = ProfileHandler.new(self)
        p.update_from_row(ds,row)
        p.save!
      end
    end
  end

  def update_users(ds)
    ds = init_ds(ds)
    ds_each_row(ds) do |row|
      @response.capture do
        p = find_profile_for_row(row)
        begin @response.warn("user doesn't exist #{identify(row)}"); next; end unless p
        p.update_from_row(ds,row)
        p.save!
      end
    end
  end

  def sync_users(ds)
    ds = init_ds(ds)
    ds_each_row(ds) do |row|
      @response.capture do
        p = find_profile_for_row(row) || ProfileHandler.new(self)
        p.update_from_row(ds,row)
        p.save!
      end
    end
    @profiles.each { |p| deactivate_profile(p) unless p.visited }
  end

  def export_csv(io,options={})
    io = File.open(io,'w') if io.is_a?(String)
    cols = @valid_columns_set.dup
    cols.subtract(['old_sso_id','old_login','password','roles'])
    cols = cols.to_a.sort!
    cols.map! { |c| annotate_column(c) } unless options[:all_fields]==true
    vals = []
    csv = FCSV.new(io)
    csv << cols
    @profiles.each do |p|
      next if p.profile.status<0 || p.profile.user.sync_exclude?
      next if p.profile.user.login.blank? and p.profile.user.sso_id.blank? # filter bad records (dev/test)
      cols.each_index do |i|
        v = p[cols[i]]
        if options[:all_fields] == true && (cols[i]=~/^profile_/ || cols[i]=~/^question_/)
          vals[i] = (v.nil? ? nil : true)
        else
          vals[i] = (v.nil? ? nil : v.to_s)
        end
      end
      @response.inc(:exported_users)
      csv << vals
    end
    io.close unless options[:close_io]==false
  end

  def identify(item)
    i = {}
    if item.is_a?(Hash)
      i[:login] = item['login']
      i[:sso_id] = item['sso_id']
    else
      i[:user_id] = item.profile.user.id
      i[:login] = item.profile.user.login
      i[:sso_id] = item.profile.user.sso_id
      i[:screen_name] = item.profile.screen_name
    end
    i.delete_if { |k,v| v.nil? }
    i.inspect
  end

  def fail_if_excluded!(ph)
    raise "User is marked as excluded from synchronization #{identify(ph)}" if ph.profile.user.sync_exclude?
  end

  private

  @@new_only_columns = ['karma_points','knowledge'].to_set
  def annotate_column(col)
    return col unless @@new_only_columns.member?(col) || col=~/^profile_/ || col=~/^question_/
    "#{col}[n]"
  end

  def ds_each_row(ds,&block)
    while row=ds.next_row
      @response.inc(:total_records)
      begin @response.fail("entries with blank sso_id and login detected, ignoring",false); next; end if row['sso_id'].blank? and row['login'].blank?
      yield(row)
    end
  end

  def init_ds(ds)
    ds = DataSource.new(CSVReader.new(File.open(ds,'r'))) if ds.is_a?(String)
    @response.ds = ds
    @response.fail("invalid columns: #{ds.columns_set.dup.subtract(@valid_columns_set).to_a.join(',')}") unless ds.columns_set.subset?(@valid_columns_set)
    @response.fail("you must have a login or sso_id column") unless ds.columns_set.member?('login') || ds.columns_set.member?('sso_id')
    ds
  end

  def find_profile_for_row(row)
    @profiles_by_eid[row['sso_id']] || @profiles_by_eid[row['old_sso_id']] || @profiles_by_login[row['login']] || @profiles_by_login[row['old_login']]
  end

  def deactivate_profile(ph)
    return if ph.profile.status == -1 || ph.profile.user.sync_exclude? # already deactivated
    @response.inc :deactivated
    @response.info "deactivating profile #{identify(ph)}"
    ph.profile.status = -1
    ph.profile.visible = false
    ph.profile.save! if commit_changes?
  end

end