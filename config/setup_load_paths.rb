require 'rubygems'
require 'bundler/setup'

# SSJ 2012-8-10 To test correct loading of rack version
# uncomment the following line, which should present an error message through Passenger displaying which version of rack is loaded
# fail "\n\n******************** RACK VERSION =  #{Gem.loaded_specs["rack"].version.to_s}  ********************\n\n"