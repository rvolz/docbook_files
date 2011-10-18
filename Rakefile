#-*- encoding:utf-8 ; mode:ruby -*-
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => 'spec'
task 'gem:release' => 'spec'

Bones {
  name         'docbook_files'
  authors      'Rainer Volz'
  email        'dev@textmulch.de'
  url          'http://rvolz.github.com/docbook_files/'
  ignore_file  '.gitignore'
  exclude      << 'dbf-about.org'
  depend_on    'libxml-ruby'
  depend_on    'term-ansicolor'
  depend_on    'wand'
  depend_on    'zucker'
  depend_on    'rspec', :development => true
  gem.extras[:license] = 'MIT'
  gem.extras[:post_install_message] = <<-POST_INSTALL_MSG

Please note:

- docbook_files uses color to mark problematic files.
On Windows, you should additionally install the gem 'win32console'
to enable color output in the terminal.

- JSON output is optional for Ruby 1.8. Please install the gem 'json'
if you are running Ruby 1.8 and want JSON output.

POST_INSTALL_MSG
}
