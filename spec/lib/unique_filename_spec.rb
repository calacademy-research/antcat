# coding: UTF-8
require 'spec_helper'

describe UniqueFilename do
  it "should simply return the filename if it doesn't already exist" do
    File.stub!(:exist?).and_return false
    UniqueFilename.get('directory', 'foo').should == 'foo'
  end
  it "should simply return the next sequential filename if it does already exist" do
    File.should_receive(:exist?).ordered.and_return true
    File.should_receive(:exist?).ordered.and_return true
    File.should_receive(:exist?).ordered.and_return false
    UniqueFilename.get('directory', 'foo').should == 'foo_2'
  end
  it "return just the name portion (in case IE gives us the full path)" do
    File.should_receive(:exist?).ordered.and_return false
    UniqueFilename.get('directory', '/foo/bar.fb').should == 'bar.fb'
  end
  it "should convert spaces and punctuation to underscores" do
    File.should_receive(:exist?).ordered.and_return false
    UniqueFilename.get('directory', 'foo bar!.fb').should == 'foo_bar.fb'
  end
end
