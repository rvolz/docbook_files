# -*-encoding:utf-8-*-

require 'optparse'
require 'yaml'
require 'json'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end
  
module DocbookFiles
  
  # Create a new instance of App, and run the +docbook_files+ application given
  # the command line _args_.
  #
  def self.run( args = nil )
    args ||= ARGV.dup.map! { |v| v.dup }
    ::DocbookFiles::App.new.run args
  end
  
  class App
    @@banner = <<EOB
docbook_files, Version #{DocbookFiles::VERSION}

Displays the include hierarchy of a DocBook 5 project. 
Use the options to see additional information about each file. 
Files that could not be found are shown in red.

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
      @props = [:name, :full_name, :namespace, :docbook,
                :version, :tag, :parent, :exists, :ts, :size, :checksum, :mime]
    end

    def run(args)
      opts = OptionParser.new
      opts.on('--details','List file details') {|val| @opts[:details] = true}
      opts.on('--outputformat=yaml|json',['json','yaml'],
              'Return the result in YAML or JSON format instead of printing it') {|format|
        case
        when format == 'yaml'
          @opts[:output_format] = :yaml
        when format == 'json'
          @opts[:output_format] = :json
        else
          STDERR.puts "Unknown output format #{format}. Using screen output.".orange
        end
      }      
      opts.banner = @@banner
      rest = opts.parse(args)

      # Print banner if called without arguments
      if rest.length < 1
        @stdout.puts opts.to_s 
        exit 1
      end

      # The main routine
      @stdout.puts("docbook_files, Version #{DocbookFiles::VERSION}") if @opts[:output_format] == :screen
      unless File.exists?(rest[0])
        @stderr.puts "Error: File #{rest[0]} not found.".red
        exit 1
      end

      begin
        dbf = DocbookFiles::Docbook.new(rest[0])
        table = dbf.list_as_table(@props)
      rescue => exc
        @stderr.puts exc.inspect.red
      end
      output(table)
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
      table.each do |t|
        output = output_string % [t[:level],
                                  format_name(t[:level],t[:full_name],table[0][:full_name]),
                                  t[:type].to_s,
                                  format_size(t[:size])]
        sum_size += t[:size]
        if t[:exists] == false
          @stdout.puts output.red
          sum_not_existing += 1
        else
          @stdout.puts output
        end
      end
      @stdout.puts '-'*80
      summary = "#{table.length} file(s) with approx. #{format_size(sum_size)}."
      if sum_not_existing > 0
        summary += " #{sum_not_existing} file(s) not found.".red
      end
      @stdout.puts summary
      if @opts[:details]
        @stdout.puts
        @stdout.puts "Details".bold
        table.each do |t|
          fname = format_name(0,t[:full_name],table[0][:full_name])
          @stdout.puts "File: %s" % [(t[:exists] ? fname : fname.red)]
          if (t[:type] == FileData::TYPE_MAIN)
            @stdout.puts "Main file"
          elsif (t[:type] == FileData::TYPE_INCLUDE)
            @stdout.puts "Included by: %s" % [t[:parent]]
          else
            @stdout.puts "Referenced by: %s" % [t[:parent]]
          end
          next unless t[:exists]
          @stdout.puts "Size: %s (%d)" % [format_size(t[:size]),t[:size]]
          if t[:docbook]
            @stdout.puts "Type: DocBook, Version #{t[:version]}, Tag: #{t[:tag]}"
          else
            @stdout.puts "MIME: #{val_s(t[:mime])}, "+
              "Namespace: #{val_s(t[:namespace])}, Tag #{val_s(t[:tag])}"
          end
          @stdout.puts "Timestamp: %s" % [t[:ts]]
          @stdout.puts "Checksum: %s" % [t[:checksum]]          
          @stdout.puts
        end
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
      main_dir = File.dirname(main_name)
      md = full_name.match("^#{main_dir}/")
      if md.nil?
        nname = full_name
      else
        nname = md.post_match
      end
      lnname = '  '*level+nname
      if (lnname.length > 60)
        lnname[0..3]+'...'+lnname[-54,lnname.length-1]
      else
        lnname
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
        '-'
      else
        case
        when sz < KB then  "#{sz}B"
        when sz >= KB && sz < MB then "#{sz/KB}KB"
        when sz >= MB && sz < GB then "#{sz/MB}MB"
        when sz >= GB && sz < TB then "#{sz/GB}GB"
        when sz >= TB && sz < PB then "#{sz/TB}TB"
        else
          "XXL"
        end
      end
    end

    # Return a string for the value, '<>' if there is none.
    def val_s(val)
      if emptyval?(val)
        '-'
      else
        val.to_s
      end
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
