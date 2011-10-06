module DocbookFiles
	require 'date'

	# Data about a member file of a DocBook project
	class FileData

		attr_accessor :name, :full_name, :ts, :includes

		def initialize(name,parent_dir=".")
			@name = name
			@full_name = get_full_name(name, parent_dir)
			@name = File.basename(name)						
			if (File.exists?(@full_name))
				@ts  = File.mtime(full_name)
				@exists = true
			else
				@ts = Time.now
				@exists = false
			end
			@includes = []
		end

		def exists?()
			@exists
		end

		# Return a tree-like array with all names
		def names()
			if @includes.empty?()
				[@name]
			else
				[@name] + @includes.map {|i| i.names}
			end
		end

private
		# Produce the full path for a filename
	  	def get_full_name(fname, parent_dir)
	    	dir = File.dirname(fname)
	    	file = File.basename(fname)
	    	full_name = File.expand_path(file,dir)
	    	unless File.exists?(full_name)
	      		full_name = File.expand_path(fname, parent_dir)
	    	end
	    	full_name
	  	end
		
	end
end
