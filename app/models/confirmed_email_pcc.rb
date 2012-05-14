require 'csv'

class ConfirmedEmailPcc < ActiveRecord::Base

  def self.match(email, pcc)
    # CHECK FOR EXACT MATCH
    if find_by_email_and_pcc(email, pcc)
      true
    # OK. Really if the email addresses matches, that's good enough
    elsif find_by_email(email)
      true
    # CHECK FOR PCC MATCH AND SAME EMAIL EXTENSION
    elsif matches = find_all_by_pcc(pcc)
      matches.any?{ |m| m.email.split("@").last == email.split("@").last }
    else
      false
    end
  end

  def self.import_from_csv(path)
    rows = []
    
    # Trouble with 'Invalid CSV'
    # Writing my own (MM2)

    # 1.9.2
    # rows = CSV.read(path)
    
    # CSV.open(path, 'r') do |row|
    #   rows << row
    # end
    
    f = File.read(path)    
    
    f_rows = f.split(/\r/)
    
    f_rows.each do |f_row|
      rows << f_row.split(",")
    end
    
    rows.each do |row|
      email = row[0].to_s.strip.downcase.gsub("\"","")
      pcc = row[1].to_s.strip.gsub("\"","")
      find_or_create_by_email_and_pcc(email, pcc)
    end  
  end

end
