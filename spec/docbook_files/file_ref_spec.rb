# -*- encoding: utf-8 -*-
require_relative '../spec_helper'
require 'time'

module  DocbookFiles 
  describe FileRef do
    
    before(:each) do
      FileData.reset()
    end
    
    it "converts a single FileRef instance to a hash" do
      f = FileRef.new("spec/fixtures/bookxi.xml")
      actual = f.to_hash([:name,:mime,:size],FileRefTypes::TYPE_MAIN)
      actual.should == {:type => :main, :name=>"bookxi.xml", :mime=>"application/xml", :size=>481}
      actual = f.to_hash([:name, :full_name, :namespace, :docbook, :version,
                          :tag, :parent, :status, :ts, :size, :checksum, :mime],
                         FileRefTypes::TYPE_MAIN)
      expected = {:type => :main, :name=>"bookxi.xml", 
        :full_name=>File.expand_path(".")+"/spec/fixtures/bookxi.xml", 
        :namespace=>"", :docbook=>false,
        :version=>"", :tag=>"", :parent=>nil, :status=>FileData::STATUS_OK, 
        :ts=>File.mtime(File.expand_path(".")+"/spec/fixtures/bookxi.xml"), :size=>481, 
        :checksum=>"7d240e7a084c16665ac59e5b927acd6a06953897", :mime=>"application/xml"}
      actual.should == expected
    end

    it "converts a FileRef tree to an array of hashes" do
      f1 = FileRef.new("spec/fixtures/bookxi.xml")
      f2 = FileRef.new("spec/fixtures/chapter2xi.xml")
      f3 = FileRef.new("spec/fixtures/chapter3xi.xml")
      f1.includes = [f2]
      f2.includes = [f3]
      expected = [{:type => :main, :name=>"bookxi.xml", :mime=>"application/xml", :size=>481}, 
                  [{:type => :inc, :name=>"chapter2xi.xml", :mime=>"application/xml", :size=>366}, 
                   [{:type => :inc, :name=>"chapter3xi.xml", :mime=>"application/xml", :size=>286}]]]
      actual = f1.traverse([:name,:mime,:size],FileRefTypes::TYPE_MAIN)
      actual.should == expected
    end
    
    it "converts a FileRef tree to a table of hashes" do
      f1 = FileRef.new("spec/fixtures/bookxi.xml")
      f2 = FileRef.new("spec/fixtures/chapter2xi.xml")
      f3 = FileRef.new("spec/fixtures/chapter3xi.xml")
      f1.includes = [f2]
      f2.includes = [f3]
      expected = [{:type => :main, :name=>"bookxi.xml", :mime=>"application/xml", :size=>481, :level=>0}, 
                  {:type => :inc, :name=>"chapter2xi.xml", :mime=>"application/xml", :size=>366, :level=>1}, 
                  {:type => :inc, :name=>"chapter3xi.xml", :mime=>"application/xml", :size=>286, :level=>2}]
      actual = f1.traverse_as_table([:name,:mime,:size])
      actual.should == expected
    end

    it "finds non-existing files" do
      f1 = FileRef.new("spec/fixtures/bookxi.xml")
      f2 = FileRef.new("spec/fixtures/chapter2xi.xml",".",f1)
      f3 = FileRef.new("spec/fixtures/chapter3xi.xml",".",f2)
      f5 = FileRef.new("spec/fixtures/non-existing.xml",".",f2)
      f1.includes = [f2]
      f2.includes = [f3,f5]
      expected = [{:type => :inc, :name=>"non-existing.xml", :parent=>"chapter2xi.xml"}]
      actual = f1.find_non_existing_files()
      actual.should  == expected
    end

    it "collects includes of all FileRef instances" do
      f1 = FileRef.new("spec/fixtures/bookxi.xml")
      f2 = FileRef.new("spec/fixtures/chapter2xi.xml",".",f1)
      f3 = FileRef.new("spec/fixtures/chapter3xi.xml",".",f2)
      f5 = FileRef.new("spec/fixtures/non-existing.xml",".",f2)
      f6 = FileRef.new("spec/fixtures/c4/chapter4xi.xml",".",f1)
      f7 = FileRef.new("spec/fixtures/non-existing.xml",".",f7)
      f1.includes = [f2,f6]
      f2.includes = [f3,f5]
      f6.includes = [f7]
      store = FileData.storage
      fr = store[f7.file_data.key]
      fr.included_by.map{|ib|ib.key}.should == [f2.file_data.key, f6.file_data.key]
    end
    
    it "collects references of all FileRef instances" do
      f1 = FileRef.new("spec/fixtures/bookxi.xml")
      f2 = FileRef.new("spec/fixtures/chapter2xi.xml",".",f1)
      f3 = FileRef.new("spec/fixtures/pic1.jpg",".",f2)
      f5 = FileRef.new("spec/fixtures/pic2.jpg",".",f2)
      f6 = FileRef.new("spec/fixtures/c4/chapter4xi.xml",".",f1)
      f7 = FileRef.new("spec/fixtures/pic2.jpg",".",f7)
      f1.includes = [f2,f6]
      f2.refs = [f3,f5]
      f6.refs = [f7]
      store = FileData.storage
      fr = store[f7.file_data.key]
      fr.referenced_by.map{|ib|ib.key}.should == [f2.file_data.key, f6.file_data.key]
    end    
  end
end

