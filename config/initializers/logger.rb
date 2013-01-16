# Monkeypatching the add method to change the format of the messages
module ActiveSupport
  
  class BufferedLogger
    @@severities = {
      0 => 'DEBUG',
      1 => 'INFO',
      2 => 'WARN',
      3 => 'ERROR',
      4 => 'FATAL',
      5 => 'UNKNOWN'
    }
    
    def <<(message)
      add(1, message)
    end
    
    def write(message)
      severity = 1
      severity = 3 if message[/err/i]
      add(severity, message)
      rescue
        add(3, "Unable to add error message!")
    end
    
    
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      prefix = "[#{Time.now.utc.strftime("%Y-%m-%d  %H:%M:%S")}] #{@@severities[severity]}:"
      message = "#{prefix} #{message}"
      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end
