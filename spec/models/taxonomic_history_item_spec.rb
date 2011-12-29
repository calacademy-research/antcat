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
  it "can belong to a taxon" do
    taxon = Factory :family
    item = taxon.taxonomic_history_items.create! :text => 'foo'
    item.reload.taxon.should == taxon 
  end
end
