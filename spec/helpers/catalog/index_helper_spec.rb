# coding: UTF-8
require 'spec_helper'

describe Catalog::IndexHelper do

  describe "Hide link" do
    it "should create a link with all the current parameters + hide_tribe => true" do
      taxon = Factory :genus
      helper.hide_link('tribes', taxon, {}).should == %{<a href="/catalog/index/#{taxon.id}?hide_tribes=true" class="hide">hide</a>}
    end
  end

  describe "Show child link" do
    it "if child is hidden, should create a link with all the current parameters and without hide_tribe" do
      taxon = Factory :genus
      helper.show_child_link({:hide_tribes => true}, 'tribes', taxon, {}).should == %{<a href="/catalog/index/#{taxon.id}">show tribes</a>}
    end
    it "if child is not hidden, return nil" do
      taxon = Factory :genus
      helper.show_child_link({}, 'tribes', taxon, {}).should be_nil
    end
  end

  describe "Delegation to CatalogFormatter" do
    it "status labels" do
      CatalogFormatter.should_receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      CatalogFormatter.should_receive(:format_statistics).with(1, :include_invalid => true)
      helper.format_statistics 1, true
    end
  end

end
