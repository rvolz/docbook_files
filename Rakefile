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
  url          'FIXME (project homepage)'
  ignore_file  '.gitignore'
  depends_on   'libxml-ruby'
}
