require 'rubygems'
require 'net/ldap'
require 'set'
require 'csv'

class SabreSync
  
  def initialize

    $stdout.sync = true

    # Establish LDAP connection
    @ldap = Net::LDAP.new
    @ldap.host = 'sgcdcdc04.global.ad.sabre.com'
    @ldap.port = 389
    @ldap.auth Config.require('sabre_ldap_login'), Config.require('sabre_ldap_password')
    unless @ldap.bind
      puts 'authentication failed'
      return
    end
    
  end
  
  def export_csv(io)
    
    io = File.open(io,'w') if io.is_a?(String)
    
    treebase = 'OU=PROD,dc=global,dc=ad,dc=sabre,dc=com'
    attribs = ['givenname','sn','mail','employeestatus','employeelastname','employeefirstname','samaccountname','physicaldeliveryofficename','telephonenumber','legacyexchangedn','radid']
    
    # it would seem machine/eds accounts dont have accessid set
    fc = Net::LDAP::Filter
    filter = fc.eq('samaccountname','SG0*') & fc.eq('mail','*') & ~fc.eq('employeestatus','0') & ~fc.eq('employeestatus','4') & ~fc.eq('name','*Mailbox*')

    csv_columns = ['sso_id','old_sso_id','screen_name','first_name','last_name','alt_first_name','alt_last_name','profile_5','profile_4','email','status']
    
    CSV::Writer.generate(io) do |csv|
      
      csv << csv_columns
      row = {}
      
      ['NA','INTL','LATAM','IgoUgo'].each do |ou|
        
        @ldap.search(:base => "OU=#{ou},#{treebase}", :filter => filter, :attributes => attribs) do |ldap_entry|
  
          $stdout.print('.')
  
          entry = {}
          # all values returned as arrays, set to 0-element
          ldap_entry.each { |key,value| entry[key.to_s] = value[0] }
        
          # discard invalid records
          next if ignore_entry?(entry)
          
          row.clear
          
          row['status'] = (entry['employeestatus'].to_s.strip=='2' ? 'inactive' : 'active' )
  
          row['sso_id'] = entry['samaccountname'].downcase
          row['old_sso_id'] = get_legacy_eid(entry)
          
          row['email'] = entry['mail']
          
          row['first_name'] = entry['givenname']
          row['last_name'] = entry['sn']
          row['alt_first_name'] = entry['employeefirstname']
          row['alt_last_name'] = entry['employeelastname']          
          
          screen_name = "#{entry['givenname']} #{entry['sn']}"
          # filter out odd characters
          screen_name.gsub!(/[\t\,\'\(\)\`]/,'')
          screen_name.gsub!(/[\.\_]/,' ')
          # only allow single spaces
          screen_name.gsub!(/\s\s+/,' ')
          row['screen_name'] = screen_name
          
          row['profile_4'] = entry['physicaldeliveryofficename']
          row['profile_5'] = entry['telephonenumber']
          
          csv << csv_columns.map { |k| row[k] }
        
        end
      end  
      
    end
  end
  
  private
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
  
end