def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

gemspec

if next?
  gem "rails", "4.0.13"
else
  gem "rails", "3.2.22.5"
end

group :development,:test do
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'test-unit'
end
