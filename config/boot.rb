require 'rubygems'

if File.exists?(".env")
  env = File.read(".env").split("\n")
  env.each do |line|
    key, value = line.split("=")
    ENV[key] ||= value
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
