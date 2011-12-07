module Synthesis
  class AssetPackage

    # class variables
    @@asset_packages_yml = $asset_packages_yml ||
      (File.exists?("#{RAILS_ROOT}/config/asset_packages.yml") ? YAML.load_file("#{RAILS_ROOT}/config/asset_packages.yml") : nil) ||
      (File.exists?("#{CubelessBase::Engine.root}/config/asset_packages.yml") ? YAML.load_file("#{CubelessBase::Engine.root}/config/asset_packages.yml") : nil) #Fix for engine based cubeless
    
    # singleton methods
    class << self

      def merge_environments=(environments)
        @@merge_environments = environments
      end

      def merge_environments
        @@merge_environments ||= ["production"]
      end

      def parse_path(path)
        /^(?:(.*)\/)?([^\/]+)$/.match(path).to_a
      end

      def find_by_type(asset_type)
        @@asset_packages_yml[asset_type].map { |p| self.new(asset_type, p) }
      end

      def find_by_target(asset_type, target)
        puts "::::::::::::::"
        puts @@asset_packages_yml
        
        package_hash = @@asset_packages_yml[asset_type].find {|p| p.keys.first == target }
        package_hash ? self.new(asset_type, package_hash) : nil
      end

      def find_by_source(asset_type, source)
        path_parts = parse_path(source)
        package_hash = @@asset_packages_yml[asset_type].find do |p|
          key = p.keys.first
          p[key].include?(path_parts[2]) && (parse_path(key)[1] == path_parts[1])
        end
        package_hash ? self.new(asset_type, package_hash) : nil
      end

      def targets_from_sources(asset_type, sources)
        package_names = Array.new
        sources.each do |source|
          package = find_by_target(asset_type, source) || find_by_source(asset_type, source)
          package_names << (package ? package.current_file : source)
        end
        package_names.uniq
      end

      def sources_from_targets(asset_type, targets)
        source_names = Array.new
        targets.each do |target|
          package = find_by_target(asset_type, target)
          source_names += (package ? package.sources.collect do |src|
            package.target_dir.gsub(/^(.+)$/, '\1/') + src
          end : target.to_a)
        end
        source_names.uniq
      end

      def build_all
        @@asset_packages_yml.keys.each do |asset_type|
          @@asset_packages_yml[asset_type].each { |p| self.new(asset_type, p).build }
        end
      end

      def delete_all
        @@asset_packages_yml.keys.each do |asset_type|
          @@asset_packages_yml[asset_type].each { |p| self.new(asset_type, p).delete_previous_build }
        end
      end

      def create_yml
        unless File.exists?("#{RAILS_ROOT}/config/asset_packages.yml")
          asset_yml = Hash.new

          asset_yml['javascripts'] = [{"base" => build_file_list("#{RAILS_ROOT}/public/javascripts", "js")}]
          asset_yml['stylesheets'] = [{"base" => build_file_list("#{RAILS_ROOT}/public/stylesheets", "css")}]

          File.open("#{RAILS_ROOT}/config/asset_packages.yml", "w") do |out|
            YAML.dump(asset_yml, out)
          end

          log "config/asset_packages.yml example file created!"
          log "Please reorder files under 'base' so dependencies are loaded in correct order."
        else
          log "config/asset_packages.yml already exists. Aborting task..."
        end
      end

    end

    # instance methods
    attr_accessor :asset_type, :target, :target_dir, :sources

    def initialize(asset_type, package_hash)
      target_parts = self.class.parse_path(package_hash.keys.first)
      @target_dir = target_parts[1].to_s
      @target = target_parts[2].to_s
      @sources = package_hash[package_hash.keys.first]
      @asset_type = asset_type
      @asset_path = ($asset_base_path ? "#{$asset_base_path}/" : "#{RAILS_ROOT}/public/") +
          "#{@asset_type}#{@target_dir.gsub(/^(.+)$/, '/\1')}"
      @extension = get_extension
      @file_name = "#{@target}_packaged.#{@extension}"
      @full_path = File.join(@asset_path, @file_name)
    end

    def package_exists?
      File.exists?(@full_path)
    end

    def current_file
      build unless package_exists?

      path = @target_dir.gsub(/^(.+)$/, '\1/')
      "#{path}#{@target}_packaged"
    end

    def build
      delete_previous_build
      create_new_build
    end

    def delete_previous_build
      File.delete(@full_path) if File.exists?(@full_path)
    end

    private
      def create_new_build
        new_build_path = "#{@asset_path}/#{@target}_packaged.#{@extension}"
        if File.exists?(new_build_path)
          log "Latest version already exists: #{new_build_path}"
        else
          File.open(new_build_path, "w") {|f| f.write(compressed_file) }
          log "Created #{new_build_path}"
        end
      end

      def merged_file
        merged_file = ""
        @sources.each {|s|
          File.open("#{@asset_path}/#{s}.#{@extension}", "r") { |f|
            merged_file += f.read + "\n"
          }
        }
        merged_file
      end

      def compressed_file
        case @asset_type
          when "javascripts" then compress('js', merged_file)
          when "stylesheets" then compress('css', merged_file)
        end
      end

      def compress(type, source)
        compressor_path = "#{RAILS_ROOT}/vendor/plugins/asset_packager/lib/yuicompressor"
        tmp_path = "#{RAILS_ROOT}/tmp/#{@target}_packaged"

        # write out to a temp file
        File.open("#{tmp_path}_uncompressed.#{type}", "w") {|f| f.write(source) }

        # compress file with JSMin library
        `java -jar #{compressor_path}/yuicompressor-2.4.2.jar --type #{type} -o #{tmp_path}_compressed.#{type} #{tmp_path}_uncompressed.#{type}`

        # read it back in and trim it
        result = ""
        File.open("#{tmp_path}_compressed.#{type}", "r") { |f| result += f.read.strip }

        # delete temp files if they exist
        File.delete("#{tmp_path}_uncompressed.#{type}") if File.exists?("#{tmp_path}_uncompressed.#{type}")
        File.delete("#{tmp_path}_compressed.#{type}") if File.exists?("#{tmp_path}_compressed.#{type}")

        result
      end

      def get_extension
        case @asset_type
          when "javascripts" then "js"
          when "stylesheets" then "css"
        end
      end

      def log(message)
        self.class.log(message)
      end

      def self.log(message)
        puts message
      end

      def self.build_file_list(path, extension)
        re = Regexp.new(".#{extension}\\z")
        file_list = Dir.new(path).entries.delete_if { |x| ! (x =~ re) }.map {|x| x.chomp(".#{extension}")}
        # reverse javascript entries so prototype comes first on a base rails app
        file_list.reverse! if extension == "js"
        file_list
      end

  end
end
