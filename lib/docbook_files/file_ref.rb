# -*- encoding:utf-8 -*-
module DocbookFiles

  # A FileRef represents a file inclusion (<xi:include href='...') or
  # reference (<imagedata filref=='...') in DocBook. It points to a FileData
  # instance, that represents the actual file. Multiple FileRefs can point to
  # the same FileData.
  #
  # A FileRef contains
  # * the parent FileRef
  # * the kind of relation (included or referenced)
  # * the FileData instance
  #
  class FileRef

    # TODO file and line?
    attr_accessor :rel_type, :file_data, :parent
    attr_reader :includes, :refs
    
    def initialize(name,parent_dir=".",parent_file=nil)
      @file_data = FileData.for(name,parent_dir)
      @parent = (parent_file.nil? ? nil : parent_file.name)
      @includes = []
      @refs = []
    end

    def method_missing(name, *args, &block)
      @file_data.send(name,*args, &block)
    end

    def includes=(incs)
      @includes = incs
      @file_data.add_includes(incs.map{|inc| inc.file_data})
    end

    def refs=(refs)
      @refs = refs
      @file_data.add_references(refs.map{|ref| ref.file_data})
    end
    
    # Return a hash with the values for the passed symbols.
    # The type is added.
    # 
    # Example: to_hash([:name, :mime]) would return 
    #  {:type => "main", :name => "name", :mime => "application/xml"}.
    #
    def to_hash(props,type)
      me_hash = {:type => type}
      props.each {|p| me_hash[p] = self.send(p)}
      me_hash
    end

    # Return a tree-like array of maps with the 
    # requested properties (symbols)
    def traverse(props=[],type=FileRefTypes::TYPE_MAIN)
      me = self.to_hash(props,type)
      me2 = [me]
      unless self.refs.empty?()
        me2 += self.refs.map {|r| r.to_hash(props,FileRefTypes::TYPE_REFERENCE)}
      end
      if self.includes.empty?()
        me2
      else
        me2 + self.includes.map {|i| i.traverse(props,FileRefTypes::TYPE_INCLUDE)}
      end
    end

    # Return the names and parent files of non-existing files
    def find_non_existing_files
      files = traverse([:name, :status, :parent])
      files.flatten.reject{|f| f[:status] != FileData::STATUS_NOT_FOUND}.map{|f| f.delete(:status); f}
    end

    # Return a tree-like array with all names
    def names
      self.traverse([:name])
    end

    
    # Return a table-like array of maps with the 
    # requested properties (symbols). Each entry gets a level 
    # indicator (:level) to show the tree-level.
    #
    def traverse_as_table(props,level=0,type=FileRefTypes::TYPE_MAIN)
      me = self.to_hash(props,type)
      me[:level] = level
      me2 = [me]
      unless self.refs.empty?()
        me2 += self.refs.map {|r| x = r.to_hash(props,FileRefTypes::TYPE_REFERENCE); x[:level] = level+1; x}
      end
      unless self.includes.empty?()
        me2 += self.includes.map {|i| i.traverse_as_table(props,level+1,FileRefTypes::TYPE_INCLUDE)}
      end
      me2.flatten
    end
    
  end
end
