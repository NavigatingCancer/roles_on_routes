require 'rubygems'

gemfile_name = ENV['BUNDLE_GEMFILE'] ||= 'Gemfile'
gemfile = File.expand_path("../../../../#{gemfile_name}", __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$:.unshift File.expand_path('../../../../lib', __FILE__)