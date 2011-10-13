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
  url          'http://github.com/rvolz/docbook_files/'
  ignore_file  '.gitignore'
  depend_on    'libxml-ruby'
  depend_on    'term-ansicolor'
  depend_on    'wand'
}
