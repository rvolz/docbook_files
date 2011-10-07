module DocbookFiles
	require 'date'
	require 'digest/sha1'
	require 'wand'

	# Data about a member file of a DocBook project
	class FileData

		# file name, full file path, existence flag, last modified timestamp, size in bytes
		# SHA1 checksum, MIME type, array of included FileDatas
		#attr_accessor :name, :full_name, :exists, :ts, :size, :checksum, :mime, :includes

		# XML namespace, Flag for DocBook NS, DocBook version, start tag
		#attr_accessor :namespace, :docbook, :version, :tag

		attr_accessor :name, :exists, :includes

		def FileData.init_vars()
			x = {:full_name => "file name + path",
				:ts => "last modified timestamp",
				:size => "file size",
				:checksum => "file checksum",
				:mime => "the file's MIME type",
				:namespace => "XML namespace, if applicable",
				:docbook => "DocBook type flag",
				:version => "DocBook version number, if applicable",
				:tag => "XML start tag, if applicable",
				:parent => "parent file, if included or referenced"}
			x.each  { |s,ex|
				attr_accessor s
			}
			x
		end

		@@vars = init_vars()
		

		def initialize(name,parent_dir=".",parent_file=nil)
			@name = name
			@full_name = get_full_name(name, parent_dir)
			@name = File.basename(name)		
			@namespace = ""
			@docbook = false
			@version = ""
			@tag = ""
			@parent = (parent_file.nil? ? nil : parent_file.name)
			if (File.exists?(@full_name))
				@exists = true				
				@ts  = File.mtime(full_name)
				@size = File.size(full_name)				
				@checksum = calc_checksum()
				@mime = get_mime_type()
			else
				@exists = false
				@ts = Time.now
				@size = 0
				@checksum = ""
				@mime = ""
			end
			@includes = []
		end


		# Does the really file exist?
		def exists?
			@exists
		end

		# Return the names and parent files of non-existing files
		def find_non_existing_files
			files = traverse([:name, :exists, :parent])
			files.flatten.reject{|f| f[:exists] == true}.map{|f| f.delete(:exists); f}
		end

		# Return a tree-like array with all names
		def names
			self.traverse([:name])
		end

		# Return a hash with the values for the passed symbols. 
		# If the property list is empty all instance variables 
		# are used, except the include.
		# 
		# Example: to_hash([:name, :mime]) would return 
		#  {:name => "name", :mime => "application/xml"}.
		#
		def to_hash(props=[])
			me_hash = {}
			if (props.empty?)
				ivs = self.instance_variables
				ivs.delete(:@includes)
				props = ivs.map {|iv| ivs = iv.to_s; ivs[1,ivs.length].to_sym}
			end
			props.each {|p| me_hash[p] = self.send(p)}
			me_hash
		end

		# Return a tree-like array of maps with the 
		# requested properties (symbols)
		def traverse(props=[])
			me = self.to_hash(props)
			if @includes.empty?()
				[me]
			else
				[me] + @includes.map {|i| i.traverse(props)}
			end
		end

		# Return a table-like array of maps with the 
		# requested properties (symbols). Each entry gets a level 
		# indicator (:level) to show the tree-level.
		#
		def traverse_as_table(props=[],level=0)
			me = self.to_hash(props)
			me[:level] = level
			if @includes.empty?()
				ret = [me]
			else
				ret = [me] + @includes.map {|i| i.traverse_as_table(props,level+1)}
			end
			ret.flatten
		end

private

		# Calculate the SHA1 checksum for the file
		def calc_checksum
				Digest::SHA1.hexdigest(IO.binread(@full_name))
		end

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

  	# Try to find the file's MIME type
		def get_mime_type
			Wand.wave(@full_name)
		end		

	end
end
