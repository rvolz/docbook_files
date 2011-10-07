#-*- encoding: utf-8 ; mode:ruby -*-
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name         'docbook_files'
  authors      'Rainer Volz'
  email        'dev@textmulch.de'
  url          'http://github.com/rvolz/docbook_files/'
  ignore_file  '.gitignore'
  ignore_file  'About.org'
  depends_on   'libxml-ruby'
  depends_on	 'term-ansicolor'
  depends_on	 'wand'
}
