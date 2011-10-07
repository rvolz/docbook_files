docbook_files
===========

docbook_files lists and checks all files related to a DocBook writing project.

Features
--------

* lists and checks included files

Synopsis
--------

docbook_files is a command line application, bin/docbook_files, which checks the files that are included or referenced in a DocBook 5 project. (Note: In version 0.1.0 we are only checking included files, but that will change.)

  docbook_files myproject.xml

This will result in a indentet list of the file names, starting from file _myproject.xml_ and following every XInclude link. Files that could not be found are shown in red.

Using options the output can be enhanced with more file information, use the classical _docbook_files --help_ to see all available options. They range from file size to MIME types and XML namespaces. Example:

  docbook_files --ts --namespace myproject.xml

would result in a list with the added information of the last modified timestamp and the XML namespace of each file.

Requirements
------------

* libxml2

Install
-------

* gem install docbook_files

Author
------

Rainer Volz

License
-------

The MIT License

Copyright (c) 2011 Rainer Volz

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
