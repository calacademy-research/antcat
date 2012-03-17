# coding: UTF-8
require 'spec_helper'

describe TaxonomicHistoryItem do
  it "should have some taxt" do
    item = TaxonomicHistoryItem.new :taxt => 'taxt'
    item.should be_valid
    item.save!
    item.reload
    item.taxt.should == 'taxt'
  end
  it "can belong to a taxon" do
    taxon = Factory :family
    item = taxon.taxonomic_history_items.create! :taxt => 'foo'
    item.reload.taxon.should == taxon 
  end

  describe "Updating taxt from editable taxt" do
    let(:item) {Factory :taxonomic_history_item}

    it "should pass non-tags straight through" do
      item.update_taxt_from_editable 'abc'
      item.reload.taxt.should == 'abc'
    end

    it "should convert from editable tags to tags" do
      reference = Factory :article_reference
      other_reference = Factory :article_reference
      editable_key = Taxt.id_for_editable reference.id
      other_editable_key = Taxt.id_for_editable other_reference.id

      item.update_taxt_from_editable %{{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}}
      item.reload.taxt.should == "{ref #{reference.id}}, also {ref #{other_reference.id}}"
    end

    it "should have errors if braces are unbalanced"
    it "should have errors if a reference isn't found"
  end
end
