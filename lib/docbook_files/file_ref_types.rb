# -*- encoding: utf-8 -*-

module DocbookFiles
  
  # Contains thre reference type for relations between files in DocBook.
  class FileRefTypes
    
    # Type for the main/master file
    TYPE_MAIN = :main
    
    # Type for referenced files (via fileref attribute)
    TYPE_REFERENCE = :ref
    TYPE_REFERENCED_BY = :refdby
    
    # Type for included files (XInclude)
    TYPE_INCLUDE = :inc
    TYPE_INCLUDED_BY = :incdby

  end
end
