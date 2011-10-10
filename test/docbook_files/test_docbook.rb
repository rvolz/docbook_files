# -*- encoding: utf-8 -*-
require 'minitest/spec'
require 'turn'
require "docbook_files"

MiniTest::Unit.use_natural_language_case_names = true

module  DocbookFiles 
	describe Docbook do

		it "can cope with invalid xml files" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/no-xml.xml")
			actual = dbf.list()
			actual.must_be_kind_of(DocbookFiles::FileData)
			actual.name.must_equal("no-xml.xml")
			actual.size.must_equal(15)
			actual.docbook.must_equal(false)
		end
					
		it "finds namespace, DocBookness, version" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/bookxi.xml")
			actual = dbf.list()
			actual.namespace.must_equal("http://docbook.org/ns/docbook")
			actual.docbook.must_equal(true)
			actual.version.must_equal("5.0")
		end

		it "finds no namespace, DocBookness, version" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/no-ns.xml")
			actual = dbf.list()
			actual.namespace.must_equal("")
			actual.docbook.must_equal(false)
			actual.version.must_equal("")
		end			

		it "finds a tag" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/bookxi.xml")
			actual = dbf.list()
			actual.tag.must_equal("book")
		end			

		it "lists" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/bookxi.xml")
			actual = dbf.list()
			expected = [{:name=>"bookxi.xml"}, 
				[{:name=>"chapter2xi.xml"}, [{:name=>"section1xi.xml"}]], 
				[{:name=>"chapter3xi.xml"}], [{:name=>"chapter4xi.xml"}]]
			actual.names.must_equal(expected)			
		end

		it "lists as a table" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/bookxi.xml")
			actual = dbf.list_as_table([:name])
			expected = [{:name=>"bookxi.xml", :level=>0}, 
				{:name=>"chapter2xi.xml", :level=>1}, 
				{:name=>"section1xi.xml", :level=>2}, 
				{:name=>"chapter3xi.xml", :level=>1}, 
				{:name=>"chapter4xi.xml", :level=>1}]
			actual.must_equal(expected)			
		end

		it "finds referenced files" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/refs/book-simple.xml")
			actual = dbf.list()
			actual.refs.map{|r|r.name}.must_equal(["orange.png","orange.jpeg"])
		end

		it "marks non-existing references" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/refs/book-simple-err.xml")
			actual = dbf.list()
			actual.refs.map{|r|r.name}.must_equal(["orange.png","orange.jpeg"])
			actual.refs.map{|r|r.exists}.must_equal([true,false])
		end

	end
end
