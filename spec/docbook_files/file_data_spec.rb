# -*- encoding: utf-8 -*-
require_relative '../spec_helper'
require 'time'

module  DocbookFiles 
  describe FileData do
    
    before(:each) do
      FileData.reset()
    end
 
    it "calculates a checksum" do
      f = FileData.for("spec/fixtures/bookxi.xml")
      f.checksum.should == "7d240e7a084c16665ac59e5b927acd6a06953897"
    end
    
    it "finds a XML MIME type" do
      f = FileData.for("spec/fixtures/bookxi.xml")
      f.mime.should == "application/xml"
    end
    
    it "finds a plain text MIME type" do
      pending("different MIME lib?") do
        f = FileData.for("spec/fixtures/no-xml.xml")
        f.mime.should_not == "application/xml"
      end
    end

    it "stores only one instance per file" do
      f1 = FileData.for("spec/fixtures/bookxi.xml")
      f2 = FileData.for("spec/fixtures/bookxi.xml")
      FileData.files.size .should == 1
    end
    
    it "stores includes" do
      f1 = FileData.for("spec/fixtures/bookxi.xml")
      f2 = FileData.for("spec/fixtures/chapter2xi.xml")
      f3 = FileData.for("spec/fixtures/chapter3xi.xml")
      f1.add_includes([f2,f3])
      f1s = FileData::storage[f1.key]
      f1s.includes.should == [f2, f3]
      f2s = FileData::storage[f2.key]
      f2s.included_by.should == [f1]
    end
    
    it "stores references" do
      f1 = FileData.for("spec/fixtures/bookxi.xml")
      f2 = FileData.for("spec/fixtures/chapter2xi.xml")
      f3 = FileData.for("spec/fixtures/chapter3xi.xml")
      f1.add_references([f2,f3])
      f1s = FileData::storage[f1.key]
      f1s.references.should == [f2, f3]
      f2s = FileData::storage[f2.key]
      f2s.referenced_by.should == [f1]
    end
    
  end
end

