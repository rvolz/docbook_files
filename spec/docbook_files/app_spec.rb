# -*- encoding:utf-8 -*-
require_relative '../spec_helper'
require 'stringio'

module DocbookFiles
  describe App do

    describe "displays file names" do
      
      it "according to level" do
        a = App.new
        a.format_name(0,'book.xml').should == 'book.xml'
        a.format_name(2,'chapter.xml').should == '    chapter.xml'
        a.format_name(3,'chapter.xml').should == '      chapter.xml'
      end

      it "shortened when too long" do
        a = App.new
        main_d = '/dir1/dir2'*5
        main_d2 = '/dir0/dir1/dir2'*5
        main_n = main_d+'/book.xml'
        a.format_name(2,main_d+'/chapter.xml').should ==
          '    ...r2/dir1/dir2/dir1/dir2/dir1/dir2/dir1/dir2/chapter.xml'
        expected = "    ...r0/dir1/dir2/dir0/dir1/dir2/dir0/dir1/dir2/chapter.xml"
        a.format_name(2,main_d2+'/chapter.xml').should == expected
        a.format_name(2,main_d2+'/chapter.xml').length.should == 61
      end

    end
    
    it "formats file sizes for humans" do
      a = App.new
      a.format_size(1023).should == "1023B"
      a.format_size(1024).should == "1KB"
      a.format_size(1025).should == "1KB"
      a.format_size(999*App::KB).should == "999KB"
      a.format_size(1024*App::KB).should == "1MB"
      a.format_size(3200*App::KB).should == "3MB"
      a.format_size(9999*App::MB).should == "9GB"
      a.format_size(1023*App::GB).should == "1023GB"
      a.format_size(1024 + App::TB).should == "1TB"
      a.format_size(1024 + App::PB).should == "XXL"
    end

    it "can use YAML as output format" do
      stdout1 = StringIO.new
      stderr1 = StringIO.new
      a = App.new({:stdout => stdout1, :stderr => stderr1})
      a.run(['--outputformat=yaml','spec/fixtures/bookxi.xml'])
      stderr1.string.should == ""
      stdout1.string.should_not == ""
      yml = YAML.load(stdout1.string)
      yml.size.should == 2
      hier = yml[:hierarchy]
      det = yml[:details]
      hier.size.should == 5      
      hier[0][:type].should == :main
      hier[0][:path].should == "bookxi.xml"
      hier[0][:level].should == 0
      hier[4][:type].should == :inc
      hier[4][:path].should == "c4/chapter4xi.xml"
      hier[4][:level].should == 1
      det.size.should == 5
      det[0][:path].should == "bookxi.xml"
      det[0][:error_string].should be_nil
      det[0][:includes].should == ["chapter2xi.xml", "chapter3xi.xml", "c4/chapter4xi.xml"]
      det[0][:included_by].should be_empty
      det[4][:path].should == "c4/chapter4xi.xml"
      det[4][:error_string].should be_nil
      det[4][:includes].should be_empty
      det[4][:included_by].should == ["bookxi.xml"]      
    end
    
    it "can use JSON as output format" do
      stdout1 = StringIO.new
      stderr1 = StringIO.new
      require 'json'
      a = App.new({:stdout => stdout1, :stderr => stderr1, :json_available => true})
      a.run(['--outputformat=json','spec/fixtures/bookxi.xml'])
      stderr1.string.should == ""
      stdout1.string.should_not == ""
      yml = JSON.parse(stdout1.string)
      yml.size.should == 2
      hier = yml["hierarchy"]
      det = yml["details"]
      hier.size.should == 5 
      hier[0]["type"].should == "main"
      hier[0]["path"].should == "bookxi.xml"
      hier[0]["level"].should == 0
      hier[4]["type"].should == "inc"
      hier[4]["path"].should == "c4/chapter4xi.xml"
      hier[4]["level"].should == 1
      det.size.should == 5
      det[0]["path"].should == "bookxi.xml"
      det[0]["error_string"].should be_nil
      det[0]["includes"].should == ["chapter2xi.xml", "chapter3xi.xml", "c4/chapter4xi.xml"]
      det[0]["included_by"].should be_empty
      det[4]["path"].should == "c4/chapter4xi.xml"
      det[4]["error_string"].should be_nil
      det[4]["includes"].should be_empty
      det[4]["included_by"].should == ["bookxi.xml"]            
    end
        
  end
end
