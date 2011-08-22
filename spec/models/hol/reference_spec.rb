# coding: UTF-8
require 'spec_helper'

describe Hol::Reference do

  it "should be possible to set its attributes via a hash" do
    reference = Hol::Reference.new :document_url => 'a source', :year => '2010', :series_volume_issue => '1', :pagination => '2-3'
    reference.document_url.should == 'a source'
    reference.year.should == '2010'
    reference.series_volume_issue.should == '1'
    reference.pagination.should == '2-3'
  end

  it "should be comparable" do
    Hol::Reference.new(:author => 'Bolton').should be_kind_of ComparableReference
  end

end
