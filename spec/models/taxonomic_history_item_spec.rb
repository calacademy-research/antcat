# coding: UTF-8
require 'spec_helper'

describe TaxonomicHistoryItem do
  it "should have some text" do
    item = TaxonomicHistoryItem.new :text => 'text'
    item.should be_valid
    item.save!
    item.reload
    item.text.should == 'text'
  end
end
