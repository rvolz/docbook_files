# -*- encoding: utf-8 -*-
require 'minitest/spec'
require 'turn'
require "docbook_files"
require 'date'

MiniTest::Unit.use_natural_language_case_names = true

module  DocbookFiles 
	describe FileData do
		it "initializes" do
		end
		
		it "calculates a checksum" do
			f = FileData.new("test/fixtures/bookxi.xml")
			f.checksum.must_equal("7d240e7a084c16665ac59e5b927acd6a06953897") 
		end

		it "finds a XML MIME type" do
			f = FileData.new("test/fixtures/bookxi.xml")
			f.mime.must_equal("application/xml")
		end

		it "finds a plain text MIME type" do
			skip "Different MIME lib?"
			f = FileData.new("test/fixtures/no-xml.xml")
			f.mime.wont_equal("application/xml")
		end

		it "converts a single FileData instance to a hash" do
			f = FileData.new("test/fixtures/bookxi.xml")
			actual = f.to_hash([:name,:mime,:size])
			actual.must_equal({:name=>"bookxi.xml", :mime=>"application/xml", :size=>481})
			actual = f.to_hash()
			expected = {:name=>"bookxi.xml", 
				:full_name=>"/Users/rv/Documents/Projekte/docbook_files/test/fixtures/bookxi.xml", 
				:namespace=>"", :docbook=>false, :version=>"", :tag=>"", :parent=>nil, :exists=>true, 
				:ts=>Time.parse("2011-10-06 20:45:01 +0200"), :size=>481, 
				:checksum=>"7d240e7a084c16665ac59e5b927acd6a06953897", :mime=>"application/xml", :refs => []}
			actual.must_equal(expected)			
		end

		it "converts a FileData tree to an array of hashes" do
			f1 = FileData.new("test/fixtures/bookxi.xml")
			f2 = FileData.new("test/fixtures/chapter2xi.xml")
			f3 = FileData.new("test/fixtures/chapter3xi.xml")
			f1.includes = [f2]
			f2.includes = [f3]
			expected = [{:name=>"bookxi.xml", :mime=>"application/xml", :size=>481}, 
				[{:name=>"chapter2xi.xml", :mime=>"application/xml", :size=>366}, 
					[{:name=>"chapter3xi.xml", :mime=>"application/xml", :size=>286}]]]
			actual = f1.traverse([:name,:mime,:size])
			actual.must_equal(expected)
		end

		it "converts a FileData tree to a table of hashes" do
			f1 = FileData.new("test/fixtures/bookxi.xml")
			f2 = FileData.new("test/fixtures/chapter2xi.xml")
			f3 = FileData.new("test/fixtures/chapter3xi.xml")
			f1.includes = [f2]
			f2.includes = [f3]
			expected = [{:name=>"bookxi.xml", :mime=>"application/xml", :size=>481, :level=>0}, 
				{:name=>"chapter2xi.xml", :mime=>"application/xml", :size=>366, :level=>1}, 
				{:name=>"chapter3xi.xml", :mime=>"application/xml", :size=>286, :level=>2}]
			actual = f1.traverse_as_table([:name,:mime,:size])
			actual.must_equal(expected)
		end

		it "finds non-existing files" do
			f1 = FileData.new("test/fixtures/bookxi.xml")
			f2 = FileData.new("test/fixtures/chapter2xi.xml",".",f1)
			f3 = FileData.new("test/fixtures/chapter3xi.xml",".",f2)
			f5 = FileData.new("test/fixtures/non-existing.xml",".",f2)
			f1.includes = [f2]
			f2.includes = [f3,f5]
			expected = [{:name=>"non-existing.xml", :parent=>"chapter2xi.xml"}]
			actual = f1.find_non_existing_files()
			actual.must_equal(expected)
		end

	end
end

