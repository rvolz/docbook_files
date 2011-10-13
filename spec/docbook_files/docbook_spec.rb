# -*- encoding:utf-8 -*-
require_relative '../spec_helper'

module DocbookFiles
  describe Docbook do
    
    it "can cope with invalid xml files" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/no-xml.xml")
      actual = dbf.list()
      actual.class.should == DocbookFiles::FileData
      actual.name.should == "no-xml.xml"
      actual.size.should == 15
      actual.docbook.should be_false
      actual.xml_err.should be_true
      actual.error_string.should_not be_nil
    end
    
    it "finds namespace, DocBookness, version" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/bookxi.xml")
      actual = dbf.list()
      actual.namespace.should == "http://docbook.org/ns/docbook"
      actual.docbook.should be_true
      actual.version.should == "5.0"
    end
    
    it "finds no namespace, DocBookness, version" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/no-ns.xml")
      actual = dbf.list()
      actual.namespace.should be_empty
      actual.docbook.should be_false 
      actual.version.should be_empty
    end			
    
    it "finds a tag" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/bookxi.xml")
      actual = dbf.list()
      actual.tag.should == "book"
    end			
    
    it "lists" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/bookxi.xml")
      actual = dbf.list()
      expected = [{:type => :main, :name=>"bookxi.xml"}, 
                  [{:type => :inc, :name=>"chapter2xi.xml"}, [{:type => :inc, :name=>"section1xi.xml"}]], 
                  [{:type => :inc, :name=>"chapter3xi.xml"}], [{:type => :inc, :name=>"chapter4xi.xml"}]]
      actual.names.should == expected
    end
    
    it "lists as a table" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/bookxi.xml")
      actual = dbf.list_as_table([:name])
      expected = [{:type => :main, :name=>"bookxi.xml", :level=>0}, 
                  {:type => :inc, :name=>"chapter2xi.xml", :level=>1}, 
                  {:type => :inc, :name=>"section1xi.xml", :level=>2}, 
                  {:type => :inc, :name=>"chapter3xi.xml", :level=>1}, 
                  {:type => :inc, :name=>"chapter4xi.xml", :level=>1}]
      actual.should == expected			
    end
    
    it "finds referenced files" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/refs/book-simple.xml")
      actual = dbf.list()
      actual.refs.map{|r|r.name}.should == ["orange.png","orange.jpeg"]
    end
    
    it "marks non-existing references" do
      dbf = DocbookFiles::Docbook.new("spec/fixtures/refs/book-simple-err.xml")
      actual = dbf.list()
      actual.refs.map{|r|r.name}.should == ["orange.png","orange.jpeg"]
      actual.refs.map{|r|r.exists}.should == [true,false]
    end
    
  end
end
