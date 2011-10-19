docbook_files
===========

docbook_files lists and checks all files related to a DocBook writing project.

Features
--------

* lists and checks included files (XInclude)
* lists and checks referenced files (media files and others, specified by _fileref_)
* shows errors, e.g. not existing files
* provides a detail listing
* offers alternative output formats (YAML, JSON)

Synopsis
--------

docbook_files is a command line application, bin/docbook_files, which checks the files that are included or referenced in a DocBook 5 project. 

    docbook_files myproject.xml

This will result in a overview listing of the file names, starting from file _myproject.xml_ and following every XInclude link or _fileref_ reference. _fileref_ attributes are used in _mediaobject_ tags to specify external image, video, and audio files. Files with problems are marked red.

    docbook_files --details myproject.xml

The _--details_ option adds, well yes, details to the overview: size, type information, timestamp and checksum.

If you don't like the screen output or want to integrate docbook_file into a certain workflow, just use the YAML or JSON output format instead. The option _--outputformat_ lets you specify a different output format, for example:

    docbook_files --outputformat=yaml myproject.xml

The result is printed to STDOUT. The structure returned is equivalent to the normal terminal output, except that you always get the details. 

 * hierarchy - an array of entries for each step in the file hierarchy
 ** type - file type (main, inc-luded, or ref-erenced)
 ** name - file name
 ** path - path relative to the main file
 ** status - error status: 0 = ok, 1 = file not found, 2 = processing error (see error_string)
 ** size - file size in bytes
 ** level - the level in the file hierarchy, starting with 0

 * details - an array of entries for each file used in the hierarchy
 ** name - file name
 ** path - path relative to the main file
 ** status - error status: 0 = ok, 1 = file not found, 2 = processing error (see error_string)
 ** error_string - contains an error message, if status > 0
 ** namespace - XML namespace, if applicable
 ** version - XML version attribute, if applicable
 ** docbook - true for DocBook 5 files, else false
 ** tag - start tag for XML files (chapter, book, article ...)  
 ** ts - file modification time
 ** size - file size in byte
 ** checksum - SHA1 checksum
 ** mime - MIME type
 ** includes - files that are included by this file, an array of file names
 ** included_by - files that include this file, an array of file names
 ** references - files that are referenced by this file, an array of file names
 ** referenced_by - files that reference this file, an array of file names 


Requirements
------------

* libxml2
* json (optional, if you want JSON output on Ruby 1.8)
* win32console (optional, if you want color support on MS Windows)

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
