require 'ioscan'
require 'rexml/document'
require 'benchmark'
module HotelXml

  class IndexedFile
    def initialize(file,index)
      @index = index
      @io = file
    end
    def get(id)
      offset, size = @index[id]
      return nil unless offset
      @io.seek(offset)
      @io.read(size)
    end
    def get_xml_element(id)
      (xml = get(id)) && REXML::Document.new(xml).root
    end
    def inspect
      self.to_s
    end
    def close
      @io.close
    end
  end

  # this class will create or reload indexes as needed if the files are missing or updated
  class AutoIndexedFile
    def initialize(file_path,builder)
      @file_path = file_path
      @builder = builder
      @file_index = nil
    end
    def index
      if @file_index.nil? || @file.mtime>@last_mtime
        @file = File.open(@file_path)
        index_path = @file_path+'.index'
        if !File.exists?(index_path)
          puts "building index for #{@file_path}..."
          begin
            puts Benchmark.measure {
              File.open(index_path,'w') { |ioindex| @builder.build(@file,ioindex) }
              puts Benchmark.bm { }
            }
          rescue
            File.delete(index_path)
            raise
          end
        end
        @last_mtime = @file.mtime
        puts "loading index for #{@file_path}..."
        @file_index.close if @file_index
        File.open(index_path) { |ioindex|
          @file_index = IndexedFile.new(@file,Marshal.load(ioindex))
        }
      end
      @file_index
    end
    def inspect
      self.to_s
    end
  end

  class IdAttributeIndexBuilder
    def self.build(ioxml,ioindex)
      p1, p2 = [/<Hotel PropertyID="(\d+)/,/<\/Hotel>/]
      ios = IoScanner.new(ioxml)
      map = {}
      while true
        offset_start, offset_end, md1 = ios.match_between(p1,30,p2,8,:matchdata)
        break if offset_start.nil?
        map[md1[1].to_i] = [offset_start,offset_end-offset_start]
      end
      Marshal.dump(map,ioindex)
    end
  end

  class IdElementIndexBuilder
    def self.build(ioxml,ioindex)
      p1, p2, p3 = [/<Hotels>/,/<\/Hotels>/,/<PropertyID>(\d+)</]
      ios = IoScanner.new(ioxml)
      map = {}
      while true
        offset_start, offset_end, xml = ios.match_between(p1,8,p2,9,:string)
        break if offset_start.nil?
        map[xml.match(p3)[1].to_i] = [offset_start,offset_end-offset_start]
      end
      Marshal.dump(map,ioindex)
    end
  end


end

