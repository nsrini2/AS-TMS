require 'openssl'
require 'digest/sha1'
require 'base64'

class Crypty
  
  attr_writer :key
  def initialize(key=nil,cipher_type="aes-128-cbc")
    @key = key
    @cipher = OpenSSL::Cipher::Cipher.new(cipher_type)
  end
  
  def encrypt(s)
    return nil unless @key
    c = @cipher.encrypt
    c.key = @key
    c.iv = iv = c.random_iv
    Base64.encode64(iv+c.update(s)+c.final).strip
  end
  
  def decrypt(s)
    return nil unless @key
    s = Base64.decode64(s)
    c = @cipher.decrypt
    c.key = @key
    c.iv = s[0..16]
    c.update(s[16..-1]) << c.final
  end
  alias :[] :decrypt
  
  def test(s=@cipher.random_iv)
    s==self[self.encrypt(s)]
  end

end