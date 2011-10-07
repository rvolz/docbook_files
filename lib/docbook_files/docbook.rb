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

    # The FileData tree representing the file hierarchy
    attr_reader :fd_tree
        
    def initialize(fname)
      @main_name = fname
      @fd_tree = nil
    end

    # Return the FileData tree representing the include
    # hierarchy.
    #
    def list
      @fd_tree ||= analyze_file(@main_name,File.dirname(@main_name))
      @fd_tree
    end

    # Return all file names in a tree
    def list_names
      fl = self.list()
      fl.names
    end

    # Return a _flat_ array of FileDatas, a table with 
    # level indicator. The format is easier for tabular output.
    #
    def list_as_table(props)
      tree = self.list()
      tree.traverse_as_table(props)
    end

private
    # Check whether the document has a DocBook default namespace
    def docbook?(doc)
     dbns = doc.root.namespaces.default
     (!dbns.nil? && (dbns.href.casecmp(DOCBOOK_NS) == 0))
    end

    # Get the default namespace string for the document, 
    # or an empty string if there is none
    def namespace(doc)
      ns = doc.root.namespaces.default
      unless ns.nil?
        ns.href
      else
        ""
      end
    end

    # Returns the start tag of the XML document
    def start_tag(doc)
      doc.root.name
    end

    # Reads the _version_ attribute of the root node, 
    # mainly for DocBook 5+
    def version(doc)
      doc.root['version']
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


    # Opens a XML document and looks for included or referenced files.
    # Returns a FileData object with its include-tree
    #
    def analyze_file(fname, parent_dir, parent_fd=nil)
      fl = FileData.new(fname, parent_dir, parent_fd)
      begin
        doc = XML::Document.file(fl.full_name)      
        fl.namespace = namespace(doc)
        fl.docbook = true if docbook?(doc)
        fl.version = version(doc) if fl.docbook
        fl.tag = start_tag(doc)
        files = find_xincludes(doc)
      rescue Exception => e
        files = []
      end
      fl.includes = files.map {|f| analyze_file(f,parent_dir,fl)}
      fl
    end
  end
end
