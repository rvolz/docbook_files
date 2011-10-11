docbook_files
===========

docbook_files lists and checks all files related to a DocBook writing project.

Features
--------

* lists and checks included files (XInclude)
* lists and checks referenced files (media files and others, specidifed by _fileref_)
* shows errors, e.g. not existing files
* provides a detail listing

Synopsis
--------

docbook_files is a command line application, bin/docbook_files, which checks the files that are included or referenced in a DocBook 5 project. 

   docbook_files myproject.xml

This will result in a overview listing of the file names, starting from file _myproject.xml_ and following every XInclude link or _fileref_ reference. _fileref_ attributes are used in _mediaobject_ tags to specify external image, video, and audio files. Files that could not be found are shown in red.

   docbook_files --details myproject.xml

The --details option adds, well yes, details to the overview: Size, type information, timestamp and checksum.

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
