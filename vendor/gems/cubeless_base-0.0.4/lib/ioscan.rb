require 'strscan'
class IoScanner

  #!I auto-calc buf_size
  def initialize(io)
    @io = io
    @buffer = ''
  end

  def close
    @io.close
  end

  # mms = maximum match size
  def match_next(pattern,mms,buf_size=524288)
    while true
      start_pos = @io.pos-@buffer.length
      result = pattern.match(@buffer)
      if result
        offset_begin, offset_end = result.offset(0)
        @buffer = @buffer[offset_end,@buffer.length]
        return [result,start_pos+offset_begin,start_pos+offset_end]
      else
        return nil if @io.eof?
        @buffer = @buffer[-mms..-1] if @buffer.length>mms # backup by one mms
        @buffer << (@io.read(buf_size) || '')
      end
    end

  end

  def match_between(p1,mms1,p2,mms2,return_type=nil,buf_size=524288)

    while true
      start_pos = @io.pos-@buffer.length
      match1 = p1.match(@buffer)
      if match1
        offset_begin, offset_end = match1.offset(0)
        scanr = StringScanner.new(@buffer)
        scanr.pos = offset_end
        break
      else
        return nil if @io.eof?
        @buffer = @buffer[-mms1..-1] if @buffer.length>mms1 # backup 1 mms frame
        @buffer << (@io.read(buf_size) || '')
      end
    end

    while true
      if scanr.search_full(p2,true,false)
        result = [start_pos+offset_begin,start_pos+scanr.pos]
        @buffer = scanr.string[scanr.pos..-1]
        case return_type
          when :string then result << scanr.string[offset_begin..scanr.pos]
          when :matchdata then
            str = scanr.string
            result << p1.match(str) << p2.match(str)
        end
        return result
      else
        if @io.eof?
          @buffer = ''
          return nil
        end
        scanr.terminate # moves search ptr to end
        scanr.pos>mms2 ? scanr.pos-=mms2 : scanr.pos=0 # backup search ptr 1 mms frame
        scanr << @io.read(buf_size)
      end
    end

  end

end