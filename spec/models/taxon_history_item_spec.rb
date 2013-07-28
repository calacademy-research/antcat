# coding: UTF-8
require 'spec_helper'

describe TaxonHistoryItem do
  it "can't be blank" do
    TaxonHistoryItem.new.should_not be_valid
    TaxonHistoryItem.new(taxt: '').should_not be_valid
  end
  it "should have some taxt" do
    item = TaxonHistoryItem.new :taxt => 'taxt'
    item.should be_valid
    item.save!
    item.reload
    item.taxt.should == 'taxt'
  end
  it "can belong to a taxon" do
    taxon = FactoryGirl.create :family
    item = taxon.history_items.create! :taxt => 'foo'
    item.reload.taxon.should == taxon
  end

  describe "Updating taxt from editable taxt" do
    let(:item) {FactoryGirl.create :taxon_history_item}

    it "should not blow up on blank input but should be invalid and have errors" do
      item.update_taxt_from_editable ''
      item.errors.should_not be_empty
      item.taxt.should == ''
      item.should_not be_valid
    end

    it "should pass non-tags straight through" do
      item.update_taxt_from_editable 'abc'
      item.reload.taxt.should == 'abc'
    end

    it "should convert from editable tags to tags" do
      reference = FactoryGirl.create :article_reference
      other_reference = FactoryGirl.create :article_reference
      editable_key = Taxt.id_for_editable reference.id, 1
      other_editable_key = Taxt.id_for_editable other_reference.id, 1

      item.update_taxt_from_editable %{{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}}
      item.reload.taxt.should == "{ref #{reference.id}}, also {ref #{other_reference.id}}"
    end

    it "should have errors if a reference isn't found" do
      item.errors.should be_empty
      item.update_taxt_from_editable '{123}'
      item.errors.should_not be_empty
    end

  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        history_item = FactoryGirl.create :taxon_history_item
        history_item.versions.last.event.should == 'create'
      end
    end
  end

end
