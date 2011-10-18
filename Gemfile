#-*- encoding: utf-8 ; mode:ruby -*-
source "http://rubygems.org"
gem "libxml-ruby", :require => 'xml'
gem "term-ansicolor"
gem "wand"
gem "zucker"
gem "json", :platforms => :ruby_18
gem "win32console", :platforms => :mingw

group :development do
  gem "bones"
  gem 'rspec'
  gem 'guard'
  gem 'guard-rspec'
end
group :darwin do
  gem 'rb-fsevent', :require => false
  gem 'growl_notify', :require => false
end
group :linux do
  gem 'rb-inotify', :require => false
  gem 'libnotify', :require => false
end

