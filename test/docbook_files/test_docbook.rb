# -*- encoding: utf-8 -*-
require 'minitest/spec'
require 'minitest/autorun'
require "docbook_files"
require 'turn'

module  DocbookFiles 
	describe Docbook do
		it "lists" do
			dbf = DocbookFiles::Docbook.new("test/fixtures/bookxi.xml")
			actual = dbf.list()
			expected = ["bookxi.xml", 
						["chapter2xi.xml", 
						 ["section1xi.xml"]], 
						["chapter3xi.xml"], 
						["chapter4xi.xml"]]
			actual.names.must_equal(expected)			
		end
	end
end
