require 'rubygems'
require 'net/ldap'
require 'set'

class SyncSabreUsersToBambora

  # Contact Cindy Manning <cindy.manning@eds.com> for details on AD/LDAP if needed.

  # EmployeeStatusCode (sent from Kamble, Bharat, 7/27/07)
  # 0 = Inactive
  # 1 = Employee
  # 2 = Leave of Absence
  # 3 = Active
  # 4 = Off Payroll
  # 9 = Contractor
  # p = Professional Services

  def initialize
    $stdout.sync = true

    # Establish LDAP connection
    @ldap = Net::LDAP.new
    @ldap.host = 'sgcdcdc04.global.ad.sabre.com'
    @ldap.port = 389
    @ldap.auth Config['sabre_ldap_login'], Config['sabre_ldap_password']
    unless @ldap.bind
      puts 'authentication failed'
      return
    end

    # Establish a raw connection so we can stream data from the DB efficiently
    @conn = ActiveRecord::Base.clone_connection.raw_connection
    @conn.query_with_result = false

    # Cache all screen names so we have an easy reference for what names are unique or not
    @screen_names = Set.new
    res = @conn.query("select screen_name from profiles").use_result

    res.each { |rs|
      @screen_names << rs[0].downcase
    }
    res.free
    puts "cached #{@screen_names.size} screen names..."

    # Cache basic profile for comparison during the sync to see if values are changed
    @active_bam_users = {}
    res = @conn.query('select u.id, p.status, p.screen_name, u.sso_id, u.email, p.first_name, p.last_name, p.alt_first_name, p.alt_last_name from users u join profiles p on p.user_id=u.id where p.status>=0 and u.sso_id is not null').use_result
    res.each_hash { |rs|
      @active_bam_users[rs['sso_id'].downcase] = rs
    }
    res.free
    puts "cached #{@active_bam_users.size} active users with external id's..."

    # fyi: inactive/deactivate means queued for delete
    @inactive_bam_user_eids = Set.new
    res = @conn.query('select u.sso_id from users u join profiles p on u.id=p.user_id where p.status=-1 and u.sso_id is not null').use_result
    res.each { |rs|
      @inactive_bam_user_eids.add(rs[0].downcase)
    }
    res.free
    puts "cached #{@inactive_bam_user_eids.size} inactive user eids..."

  end

  # These are the names of the LDAP fields which will map to the cached bambora profile values
  @@entry_model_map = {'mail' => 'email',
                        'employeefirstname' => 'alt_first_name',
                        'employeelastname' => 'alt_last_name',
                        'givenname' => 'first_name',
                        'sn' => 'last_name'}

  def sync_all(purge=false)
    inactive_subtract_set = Set.new(@active_bam_users.keys)
    treebase = 'OU=PROD,dc=global,dc=ad,dc=sabre,dc=com'
    # it would seem machine/eds accounts dont have accessid set
    fc = Net::LDAP::Filter
    # filter = fc.eq('samaccountname','SG0*') & fc.eq('mail','*') & ~fc.eq('employeestatus','0') & ~fc.eq('employeestatus','4') & ~fc.eq('name','*Mailbox*')
    ###  Wanted to use manager as key but CEO has no manager defintion.  As a result, we are keying off of
    ###  employeeorgmap and the CEO has this entry. MANAGER Key is not inroduced into the filter
    ###  This collects all employees including contractors.
    filter =  fc.eq('samaccountname','SG0*') & ~fc.eq('ou','AmexSCC*') & ~fc.eq('ou','Conference*')   & 
             ~fc.eq('ou','Quest WebClient*') & ~fc.eq('ou','Workstations*') & ~fc.eq('ou','Functional Accounts') &    
              fc.eq('employeestatus','*') & ~fc.eq('employeestatus','4') & ~fc.eq('name','*Mailbox*') &  fc.eq('employeeorgmap','*')

      sync_users("#{treebase}",filter,inactive_subtract_set)

    if purge
      ps = @conn.prepare('update profiles set status=-1, visible=0, updated_at=now() where user_id=(select id from users u where u.sso_id=?)')
      inactive_subtract_set.each { |eid|
        puts "deactivated account #{eid}"
        ps.execute(eid)
      }
      ps.close
    else 
      puts "Purge not executed"
    end

  end

  def sync_user(user)
    treebase = 'OU=PROD,dc=global,dc=ad,dc=sabre,dc=com'
    filter = "(samaccountname=#{user})"
    sync_users(treebase,filter)
  end

  def user_status_changed(user_hash,employeestatus)
    user_status = user_hash['status'].to_i
    if employeestatus=='2'
      return user_status!=0
    else
      return user_status==0
    end
    return false
  end

  def set_profile_status(profile,employeestatus)
    profile.status = employeestatus=='2' ? 0 : 1
    profile.visible = true
  end

  @@regex_legacyExchangeDN_sgnum = /cn=(SG\d+)$/
  @@regex_radid = /SG(\d+)$/
  # old sg# can be found in an old exchange field or in the radid field
  # found that sometimes records are created with legacyExchange pointing to current eid, and changes a few days later
  # currently observing radid behavior
  def get_legacy_eid(entry)
    current_eid = entry['samaccountname'].downcase
    md = @@regex_legacyExchangeDN_sgnum.match(entry['legacyexchangedn'])
    md = md[1].downcase if md
    if md.nil? || md==current_eid
      md = @@regex_radid.match(entry['radid'])
      md = "sg0#{md[1]}" if md
    end
    md = nil if md==current_eid
    md
  end

  @@regex_training_user_mail = /^Train\.\d\d\.ctr\@sabre\.com$/
  @@regex_testing_user_mail = /\.Testing\.ctr\@sabre\.com$/
  @@regext_mailbox_lastname = Regexp.new('^mailbox',Regexp::IGNORECASE)
  def ignore_entry?(entry)
    return true if entry['samaccountname'].blank? or entry['givenname'].blank? or entry['sn'].blank? or entry['mail'].blank?
    # these are effectively obsolete with the new constraint added directly to the ldap filter
    return true if @@regex_training_user_mail.match(entry['mail']) or @@regex_testing_user_mail.match(entry['mail'])
    return true if @@regext_mailbox_lastname.match(entry['sn'])
    false
  end

  def sync_users(treebase,filter,inactive_subtract_set=Set.new)

    def hashes_equals_for_map(hash1,hash2,mapping)
      mapping.each_pair { |h1_key,h2_key|
        return false unless hash1[h1_key]==hash2[h2_key]
      }
      true
    end

    attribs = ['givenname','sn','mail','employeestatus','employeelastname','employeefirstname','samaccountname','physicaldeliveryofficename','telephonenumber','legacyexchangedn','radid', 'manager', 'employeeorgmap']
    @ldap.search(:base => treebase, :filter => filter, :attributes => attribs) do |ldap_entry|

      begin

        entry = {}
        # all values returned as arrays, set to 0-element
        ldap_entry.each { |key,value| entry[key.to_s] = value[0] }

        # discard invalid records
        next if ignore_entry?(entry)

        employeestatus = entry['employeestatus'].to_s.strip

        eid = entry['samaccountname'].downcase
        inactive_subtract_set.delete(eid)

        bam_user = @active_bam_users[eid]

        screen_name = "#{entry['givenname']} #{entry['sn']}"
        # filter out odd characters
        screen_name.gsub!(/[\t\,\'\(\)\`]/,'')
        screen_name.gsub!(/[\.\_]/,' ')
        # only allow single spaces
        screen_name.gsub!(/\s\s+/,' ')

        user = nil
        if bam_user.nil?
          if @inactive_bam_user_eids.member?(eid)
            user = User.find(:first,:conditions => ['sso_id=?',eid], :include => [:profile])
            puts "\nre-activated account #{eid} (#{screen_name})"
          else
            old_eid = get_legacy_eid(entry)
            if old_eid
              user = User.find(:first,:conditions => ['sso_id=?',old_eid], :include => [:profile])
              if user
                user.sso_id = eid
                puts "\nuser EID switched from #{old_eid} to #{eid} (#{screen_name})"
              else
                puts "\ncould not switch EID from #{old_eid} to #{eid} (old profile not found) (#{screen_name})"
              end
            end
          end
          user = User.new if user.nil?
        elsif bam_user['screen_name'].match("^#{screen_name}\\d*$").nil? or !hashes_equals_for_map(entry,bam_user,@@entry_model_map) or user_status_changed(bam_user,employeestatus)
          user = User.find(bam_user['id'], :include => [:profile])
        end

        if user

          User.transaction do

            new_user = user.new_record?
            user.email = entry['mail']
						if new_user
							user.sso_id = eid
							profile = Profile.new(:user => user)
						else
							profile = user.profile
						end

            # must call this first before manipulating screen name... since re-activating and disabled status
            # will cause screen name to return 'a former member'
            set_profile_status(profile,employeestatus)

            if !profile.screen_name.blank? && profile.screen_name.match("^#{screen_name}\\d*$").nil?
              @screen_names.delete(profile.screen_name.downcase)
              profile.screen_name = nil
            end

            # create a new unique screen_name if one doesnt exist
            if profile.screen_name.blank?
              test_screen_name = screen_name
              c = 0
              while @screen_names.member?(test_screen_name.downcase)
                test_screen_name = "#{screen_name}#{c+=1}"
              end
              profile.screen_name = test_screen_name
              @screen_names.add(profile.screen_name.downcase)
            end

            user.save!

            profile.first_name = entry['givenname']
            profile.last_name = entry['sn']
            profile.alt_first_name = entry['employeefirstname']
            profile.alt_last_name = entry['employeelastname']

            if new_user
              profile.profile_5 = entry['telephonenumber']
              profile.profile_4 = entry['physicaldeliveryofficename']
              puts "\nnew user added #{eid}"
              puts entry.inspect
            else
              puts "\nuser updated #{eid}"
              puts user.modified_attributes_changes.inspect
              puts profile.modified_attributes_changes.inspect
            end
            profile.save!

          end
        end
        $stdout.print('.')

      rescue
        puts entry.inspect if entry
        puts $!
        #raise
      end
    end
  end

end
