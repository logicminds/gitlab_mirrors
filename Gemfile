source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec-puppet", '~> 2.2.0'
  gem "puppetlabs_spec_helper"
  gem 'rspec-puppet-utils', :git => 'https://github.com/Accuity/rspec-puppet-utils.git'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "metadata-json-lint"
  gem 'puppet-syntax'
#  gem 'serverspec'
end

