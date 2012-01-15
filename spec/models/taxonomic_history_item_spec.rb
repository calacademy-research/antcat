# coding: UTF-8
require 'spec_helper'

describe TaxonomicHistoryItem do
  it "should have some taxt" do
    item = TaxonomicHistoryItem.new taxt: 'taxt'
    item.should be_valid
    item.save!
    item.reload
    item.taxt.should == 'taxt'
  end
  it "can belong to a taxon" do
    taxon = Factory :family
    item = taxon.taxonomic_history_items.create! taxt: 'foo'
    item.reload.taxon.should == taxon 
  end
end
