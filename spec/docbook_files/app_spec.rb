# -*- encoding:utf-8 -*-
require_relative '../spec_helper'

module DocbookFiles
  describe App do

    describe "displays file names" do
      it "according to level" do
        a = App.new
        main_n = '/dir1/dir2/dir3/book.xml'
        main_d = '/dir1/dir2/dir3/'
        a.format_name(0,main_n,main_n).should == 'book.xml'
        a.format_name(2,main_d+'chapter.xml',main_n).should == '    chapter.xml'
        a.format_name(3,main_d+'dir4/chapter.xml',main_n).should == '      dir4/chapter.xml'
      end

      it "in full when not below main file" do
        a = App.new
        main_n = '/dir1/dir2/dir3/book.xml'
        main_d = '/dir1/dir2/dir3/'
        a.format_name(2,'/dir1/dir2/chapter4.xml',main_n).should == '    /dir1/dir2/chapter4.xml'
      end

      it "shortened when too long" do
        a = App.new
        main_d = '/dir1/dir2'*5
        main_d2 = '/dir0/dir1/dir2'*5
        main_n = main_d+'/book.xml'
        a.format_name(2,main_d+'/chapter.xml',main_n).should == '    chapter.xml'
        expected = "    ...r0/dir1/dir2/dir0/dir1/dir2/dir0/dir1/dir2/chapter.xml"
        a.format_name(2,main_d2+'/chapter.xml',main_n).should == expected
        a.format_name(2,main_d2+'/chapter.xml',main_n).length.should == 61
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
  end
end
