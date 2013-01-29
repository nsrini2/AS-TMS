class AuditEvent < ActiveRecord::Base
  
  belongs_to :who, :class_name => 'Profile', :foreign_key => 'who_id'
  belongs_to :target, :polymorphic => true
  
  def info_hash
    url_params_decode(self.info)
  end
  
  def info_hash=(h={})
    self.info=url_params_encode_hash(h)
  end
  
  def trace_hash
    url_params_decode(self.trace)
  end
  
  def trace_hash=(h={})
    self.trace=url_params_encode_hash(h)
  end
  
  private
  
  def url_params_encode_hash(h)
    h ||= {}
    h.collect { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
  end
  
  def url_params_decode(p)
    h = {}
    p.split('&').each do |kv|
      k,v = kv.split('=')
      h[CGI.unescape(k)] = CGI.unescape(v)
    end if p
    h
  end
  
end
