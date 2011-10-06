require 'xml'
module DocbookFiles

  # Analyzes a DocBook 5 file for included and referenced files.
  class Docbook

    # The DocBook 5 namespace URL
    #
    DOCBOOK_NS = 'http://docbook.org/ns/docbook'

    # The XInclude namespace URL
    #
    XINCLUDE_NS = 'http://www.w3.org/2001/XInclude'

    def initialize(fname)
      @main_name = fname
    end

    # List all files included or referenced in the DocBook file
    #
    # * file name
    # * full path
    # * last modified timestamp
    # * file size
    # * MIME type, Namespace if XML
    # * checksum
    # * URI?
    # * exists?
    # * metadata ...
    def list
      analyze_file(@main_name,File.dirname(@main_name))
    end

    # Return all file names in a tree
    def list_names
      fl = analyze_file(@main_name,File.dirname(@main_name))
      fl.names
    end

   # Check whether the document has a DocBook default namespace
   def is_docbook?(doc)
     dbns = doc.root.namespaces.default
     (!dbns.nil? && (dbns.href.casecmp(DOCBOOK_NS) == 0))
   end

   # Check whether the document has a XInclude namespace
   def has_xinclude?(doc)
     ret = false
     doc.root.namespaces.each do |ns|
       if (ns.href.casecmp(XINCLUDE_NS) == 0)
         ret = true
         break
       end
     end
     ret
   end

   # Finds and returns all XInclude files/URLs in a document.
   #
   # OPTIMIZE implement xpointer and fallback handling for
   # xi:include? see http://www.w3.org/TR/xinclude/
   #
   def find_xincludes(doc)
     if has_xinclude?(doc)
       xincs = doc.find('//xi:include', "xi:"+XINCLUDE_NS)
       xincs.map {|x| x.attributes['href'] }
     else
       []
     end
   end


   # Open a XML document and look for included or referenced files.
   # Returns a map with the file name, the file's modification time, and the file structure.
   #
   def analyze_file(fname, parent_dir)
    fl = FileData.new(fname, parent_dir)
    doc = XML::Document.file(fl.full_name)
    files = find_xincludes(doc)
    fl.includes = files.map {|f| analyze_file(f,parent_dir)}
    fl
   end
 end
end
