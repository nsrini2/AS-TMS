require 'openssl'
require 'digest/sha2'
require 'base64'
require 'cgi'
require 'uri'

class TrustedFce

  def initialize(*args)
    @my_domain, @remote_url, @secret, @max_ttl = args
    @max_ttl ||= 300
  end
    
  def request_url(cmd,options={})
    options['tfce/nonce'] ||= new_nonce
    options['tfce/cmd'] = cmd
    @remote_url+"?"+hash_to_url_query('domain' => @my_domain, 'tfce' => encrypt_options(options))
  end
  
  def response_url(options)
    request_url(options['tfce/cmd']+"_response",options)
  end

  def new_nonce
    Time.now.to_i
  end

  def valid?(options,stored_nonce=nil)
    nonce = options['tfce/nonce'].to_i
    (new_nonce-nonce<=@max_ttl) && (stored_nonce.nil? || stored_nonce<nonce)
  end
  
  def encrypt_options(options)
    Base64.encode64(crypt(true,hash_to_url_query(options))).gsub("\n",'').tr('+/=','-_.')
  end

  def decrypt_options(encrypted_options)
    options = url_query_to_hash(crypt(false,Base64.decode64(encrypted_options.tr('-_.','+/='))))
    [options['tfce/cmd'],options]
  end
  
  def hash_to_url_query(hash)
    hash.to_a.collect! { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
  end
  
  def url_query_to_hash(url_query)
    url_query ? url_query.split('&').inject({}) { |h,kv| h.store(*kv.split('=').collect { |v| CGI.unescape(v) }); h } : {}
  end
    
  def crypt(encrypt,content)
    @digest ||= Digest::SHA2.digest(@secret,384) # 384 bits = 48 bytes, 32 for key, 16 for iv
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    if encrypt
      cipher.encrypt
      content << "\0"*(15-(content.size+15)%16) # pad to next block size with nuls
    else
      cipher.decrypt
    end
    cipher.key = @digest[0,32] # first 32 bytes 
    cipher.iv = @digest[32,16] # next 16 bytes
    cipher.padding=0
    result = cipher.update(content) << cipher.final
    result.sub!(/\x00+$/,'') unless encrypt # strip trailing nuls
    result
  end
    
end
