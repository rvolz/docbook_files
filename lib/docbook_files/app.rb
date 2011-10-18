# -*- encoding:utf-8 -*-

require 'optparse'
require 'yaml'
require 'zucker/env'

# Windows (RubyInstaller) needs the additional gem.
# If not present create dummies for the color routines.
if OS.windows?
  begin
    require 'win32console'
    require 'term/ansicolor'
    class String
      include Term::ANSIColor
    end
  rescue LoadError
    class String
      def red; self; end
      def green; self; end
      def magenta; self; end
      def bold; self; end
    end
  end
else
  require 'term/ansicolor'
  class String
    include Term::ANSIColor
  end
end
  
module DocbookFiles
  
  # Create a new instance of App, and run the +docbook_files+ application given
  # the command line _args_. Check also for JSON availability.
  #
  def self.run( args = nil )
    args ||= ARGV.dup.map! { |v| v.dup }
    opts = {}
    # For Windows and/or Ruby 1.8
    begin
      require 'json'      
      opts[:json_available] = true
    rescue LoadError
      opts[:json_available] = false
    end    
    ::DocbookFiles::App.new(opts).run args
  end

  ##
  # App class for the _binary_
  #
  # Return codes
  # * 0 - ok
  # * 1 - no arguments or file not found
  # * 2 - processing error
  #
  class App

    # Replacement for empty values
    EMPTYVAL = '-'

    # Replacement for monstrously large files sizes
    XXL_SIZE = "XXL"
    
    # Help banner
    @@banner = <<EOB
docbook_files, Version #{DocbookFiles::VERSION}

Shows the file hierarchy of a DocBook 5 project. 
Files with problems (not found, invalid ...) are marked red.

Usage: docbook_files [options] <DOCBOOK-FILE>
EOB

    def initialize(opts = {})
      opts[:stdout] ||= $stdout
      opts[:stderr] ||= $stderr
      @opts = opts
      @stdout = opts[:stdout]
      @stderr = opts[:stderr]
      @opts[:output_format] ||= :screen
      @opts[:details] ||= false
      @opts[:json_available] ||= opts[:json_available]
      @props = [:name, :full_name, :namespace, :docbook,
                :version, :tag, :status, :parent, :ts, :size, :checksum, :mime, :error_string]
    end

    def run(args)
      opts = OptionParser.new
      opts.on('--details','List file details') {|val| @opts[:details] = true}
      opts.on('--outputformat=yaml|json',['yaml','json'],
              'Return the result in YAML or JSON format') {|format|
        case
        when format == 'yaml'
          @opts[:output_format] = :yaml
        when format == 'json'
          if @opts[:json_available]
            @opts[:output_format] = :json
          else
            @stderr.puts "Error: JSON not available. Please install the json gem first."
            exit 1
          end
        else
          @stderr.puts "Error: Unknown output format #{format}."
        end
      }        
      opts.banner = @@banner
      rest = opts.parse(args)

      # Print banner if called without arguments
      if rest.length < 1
        @stdout.puts opts.to_s 
        exit 1
      end

      # Fail if argument not found
      @stdout.puts("docbook_files, Version #{DocbookFiles::VERSION}") if @opts[:output_format] == :screen
      unless File.exists?(rest[0])
        @stderr.puts "Error: File #{rest[0]} not found.".red
        exit 1
      end

      # Main
      begin
        dbf = DocbookFiles::Docbook.new(rest[0])
        table = dbf.list_as_table(@props)
      rescue => exc
        @stderr.puts "Something unexpected happend while docbook_files was running ..."
        @stderr.puts exc.inspect.red
        exit 2
      end
      unless table.nil?
        case @opts[:output_format]
        when :json
          mpath = table[0][:full_name]
          ntable = table.map{|t|
            t[:full_name] = relative2main(t[:full_name], mpath)
            t
          }
          @stdout.puts ntable.to_json
        when :yaml
          mpath = table[0][:full_name]
          ntable = table.map{|t|
            t[:full_name] = relative2main(t[:full_name], mpath)
            t
          }
          YAML.dump(ntable,@stdout)
        else
          output(table)
        end
      end
    end

    # Terminal output to @stdout
    def output(table)
      output_string = "%3d %-60s %4s %10s" 
      @stdout.puts
      @stdout.puts 'File Hierarchy'.bold
      @stdout.puts "%3s %-60s %4s %10s" % ['Lvl', 'File','Type','Size']
      @stdout.puts '-'*80
      sum_size = 0
      sum_not_existing = 0
      sum_xml_err = 0
      table.each do |t|
        output = output_string % [t[:level],
                                  format_name(t[:level],t[:full_name],table[0][:full_name]),
                                  t[:type].to_s,
                                  format_size(t[:size])]
        sum_size += t[:size]
        if t[:status] == FileData::STATUS_NOT_FOUND
          @stdout.puts output.red
          sum_not_existing += 1
        elsif t[:status] == FileData::STATUS_ERR
          @stdout.puts output.red
          sum_xml_err += 1          
        else
          @stdout.puts output
        end
      end
      @stdout.puts '-'*80
      summary = "#{table.length} file(s) with approx. #{format_size(sum_size)}."
      if sum_not_existing > 0
        summary += " #{sum_not_existing} file(s) not found.".red
      end
      if sum_xml_err > 0
        summary += " #{sum_xml_err} file(s) with errors.".red
      end
      @stdout.puts summary
      if @opts[:details]
        @stdout.puts
        @stdout.puts "Details".bold
        table.each do |t|
          fname = format_name(0,t[:full_name],table[0][:full_name])
          @stdout.puts "File: %s" % [((t[:status] == FileData::STATUS_OK) ? fname : fname.red)]
          if (t[:type] == FileData::TYPE_MAIN)
            @stdout.puts "Main file"
          elsif (t[:type] == FileData::TYPE_INCLUDE)
            @stdout.puts "Included by: %s" % [t[:parent]]
          else
            @stdout.puts "Referenced by: %s" % [t[:parent]]
          end
          unless t[:status] == FileData::STATUS_NOT_FOUND
            # show that part only if file exists
            @stdout.puts "Size: %s (%d)" % [format_size(t[:size]),t[:size]]
            if (t[:docbook])
              @stdout.puts "Type: DocBook, Version #{t[:version]}, Tag: #{t[:tag]}"
            else
              @stdout.puts "MIME: #{val_s(t[:mime])}"
            end
            @stdout.puts "Timestamp: %s" % [t[:ts]]
            @stdout.puts "Checksum: %s" % [t[:checksum]]
          end
          @stdout.puts "Error: %s" % [t[:error_string].to_s.red] unless (t[:error_string].nil?)            
          @stdout.puts
        end
      end
    end


    # Format the list of parent documents
    def format_parents(ps)
      if (ps.nil? || ps.empty?)
        EMPTYVAL
      else
        ps.map {|p| FileData.files[p].path}.join ','
      end
    end

    # Format the filename to indicate the level in the hierarchy.
    # Indentation = two spaces per level.
    #
    # If the file is located somewhere below the main file, only the
    # relative part of the path is shown, else the full path.
    # If the resulting string is too long for display it is shortened.
    #
    def format_name(level, full_name, main_name)
      nname = relative2main(full_name, main_name)
      lnname = '  '*level+nname
      if (lnname.length > 60)
        lnname[0..3]+'...'+lnname[-54,lnname.length-1]
      else
        lnname
      end
    end

    # Try to find the path of _file_name_ that is relative to the _main file_.
    # If there is no common part return the _file_name_.
    def relative2main(file_name,main_name)
      main_dir = File.dirname(main_name)
      md = file_name.match("^#{main_dir}/")
      if md.nil?
        file_name
      else
        md.post_match
      end
    end

    # :stopdoc:
    KB = 1024
    MB = 1048576
    GB = 1073741824
    TB = 1099511627776
    PB = 1125899906842624
    # :startdoc:
    
    # Format a file size for human consumption.
    # Sizes >= 1PB will return 'XXL'
    def format_size(sz)
      if (emptyval?(sz))
        EMPTYVAL
      else
        case
        when sz < KB then  "#{sz}B"
        when sz >= KB && sz < MB then "#{sz/KB}KB"
        when sz >= MB && sz < GB then "#{sz/MB}MB"
        when sz >= GB && sz < TB then "#{sz/GB}GB"
        when sz >= TB && sz < PB then "#{sz/TB}TB"
        else
          XXL_SIZE
        end
      end
    end

    # Return a string for the value, '-' if there is none.
    def val_s(val)
      emptyval?(val) ? EMPTYVAL : val.to_s
    end

    # Check whether the value is nil or empty.
    def emptyval?(val)
      if val.nil?
        true
      else
        if (val.class == String)
          val.empty?
        else
          false
        end
      end
    end
  end
end
