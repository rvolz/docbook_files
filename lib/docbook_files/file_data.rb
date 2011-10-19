# -*- encoding:utf-8 -*-
module DocbookFiles
  require 'date'
  require 'digest/sha1'
  require 'wand'

  # Represents the actual file that is included or referenced in a DocBook project.
  # For every file there should only one FileData instance, so we use a factory method
  # #FileData.for to create new instances.
  #
  class FileData

    # File exists and no error happened
    STATUS_OK = 0
    # File does not exist
    STATUS_NOT_FOUND = 1
    # Error while processing the file, see #error_string
    STATUS_ERR = 2

    # A storage for all FileData instances. 
    @@Files = {}

    # The directory of the main file. All #path names are relative to that
    @@MainDir = ""
    
    # Return the FileData storage -- for testing only
    def self.storage; @@Files; end

    # Return all existing FileData instances
    def self.files; @@Files.values; end
    
    # Reset the FileData storage -- must be done before every run!
    def self.reset
      @@Files={}
      @@MainDir = ""
    end
    
    # Factory method for FileData instances. Checks if there is already
    # an instance. 
    def self.for(name,parent_dir=".")
      full_name = get_full_name(name, parent_dir)
      # Initialize the main dir name for path construction
      @@MainDir = File.dirname(full_name) if @@Files.size == 0
      key = full_name
      if (@@Files[key].nil?)
        @@Files[key] = FileData.new(name, full_name, key, parent_dir)
      end
      @@Files[key]
    end


    attr_accessor :name, :path, :exists
    attr_accessor :status, :error_string
    attr_accessor :full_name
    # Unique key (path+checksum)
    attr_reader :key
    # SHA1 checksum, file size in bytes, mime type, last modified timestamp
    attr_reader :checksum, :size, :mime, :ts
    # XML data: namespace, docbook flag, namespace version, start tag
    attr_accessor :namespace, :docbook, :version, :tag

        
    def initialize(name, full_name, key, parent_dir=".")
      @path = relative2main(full_name)
      @full_name = full_name
      @name = File.basename(name)
      @key = key
      @namespace = ""
      @docbook = false
      @version = ""
      @tag = ""
      @error_string = nil
      @rels = []
      if (File.exists?(@full_name))
        @status = STATUS_OK
        @ts  = File.mtime(full_name)
        @size = File.size(full_name)        
        @checksum = calc_checksum(full_name)
        @mime = get_mime_type()
      else
        @status = STATUS_NOT_FOUND
        @ts = Time.now
        @size = 0
        @checksum = ""
        @mime = ""
        @error_string = "file not found"
      end      
    end


    # Does the really file exist?
    def exists?
      @status != STATUS_NOT_FOUND
    end

    # Add a one-way relationship, type and target, to self
    def add_rel(type, target)
      @rels << {:type => type, :target => target}
    end
    # Add a two-way relationship between self and a number of targets. 
    def add_rels(type, invtype, targets)
      targets.each {|t|
        self.add_rel(type, t)
        t.add_rel(invtype, self)
      }
    end
    # Get all targets for a relation
    def get_rel_targets(type)
      @rels.find_all{|rel| rel[:type] == type}.map{|r| r[:target]}
    end
    
    # Add included FileDatas. Establishes a two way relationship between self
    # and the included files:
    #
    # self -> TYPE_INCLUDE -> target
    # self <- TYPE_INCLUDED_BY <- target
    #
    # TODO: should be 'add_includes'
    def add_includes(incs)
      add_rels(FileRefTypes::TYPE_INCLUDE, FileRefTypes::TYPE_INCLUDED_BY, incs)
    end
    # Retrieves all included FileDatas
    def includes
      get_rel_targets(FileRefTypes::TYPE_INCLUDE)
    end
    # Retrieves all FileDatas that include self
    def included_by
      get_rel_targets(FileRefTypes::TYPE_INCLUDED_BY)
    end

    # Add referenced FileDatas. Establishes a two way relationship between self
    # and the referenced files:
    #
    # self -> TYPE_REFERENCE -> target
    # self <- TYPE_REFERENCED_BY <- target
    #
    def add_references(incs)
      add_rels(FileRefTypes::TYPE_REFERENCE, FileRefTypes::TYPE_REFERENCED_BY, incs)
    end
    # Retrieves all referenced files
    def references
      get_rel_targets(FileRefTypes::TYPE_REFERENCE)
    end
    # Retrieves all FileDatas that reference self
    def referenced_by
      get_rel_targets(FileRefTypes::TYPE_REFERENCED_BY)
    end
    
    # Try to find the path of _file_name_ that is relative to directory
    # of the _main file_.
    # If there is no common part return the _file_name_.
    def relative2main(file_name)
      md = file_name.match("^#{@@MainDir}/")
      if md.nil?
        file_name
      else
        md.post_match
      end
    end

    # Return a hash with the values for the passed symbols.
    # 
    # Example: to_hash([:name, :mime]) would return 
    #  {:name => "name", :mime => "application/xml"}.
    #
    def to_hash(props)
      me_hash = {}      
      props.each {|p|
        if ([:includes, :included_by, :references, :referenced_by].member?(p))
          me_hash[p] = self.send(p).map{|p2| p2.path}
        else
          me_hash[p] = self.send(p)
        end
      }
      me_hash
    end

private

    # Calculate the SHA1 checksum for the file.
    #
    #--
    # Includes hack for Ruby 1.8
    #++
    def calc_checksum(full_name)
      if RUBY_VERSION=~ /^1.8/
        contents = open(full_name, "rb") {|io| io.read }
      else
        contents = IO.binread(full_name)
      end
      Digest::SHA1.hexdigest(contents)
    end

    # Produce the full path for a filename
    def self.get_full_name(fname, parent_dir)
      dir = File.dirname(fname)
      file = File.basename(fname)
      full_name = File.expand_path(file,dir)
      unless File.exists?(full_name)
          full_name = File.expand_path(fname, parent_dir)
      end
      full_name
    end

    # Try to find the file's MIME type
    def get_mime_type
      Wand.wave(@full_name)
    end   

  end
end
