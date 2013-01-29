require 'yaml'
#require "#{Rails.root}/vendor/plugins/cubeless/vendor/plugins/asset_packager/lib/synthesis/asset_package"
require_cubeless_engine_file "vendor/plugins", "asset_packager/lib/synthesis/asset_package"

# MM2: Apparently you can get to nested plugin rake files. Copied from the asset_packager plugin.
namespace :asset do
  namespace :packager do

    desc "Merge and compress assets"
    task :build_all do
      Synthesis::AssetPackage.build_all
    end

    desc "Delete all asset builds"
    task :delete_all do
      Synthesis::AssetPackage.delete_all
    end
    
    desc "Generate asset_packages.yml from existing assets"
    task :create_yml do
      Synthesis::AssetPackage.create_yml
    end
    
  end
end