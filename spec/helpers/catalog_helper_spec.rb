# coding: UTF-8
require 'spec_helper'

describe CatalogHelper do

  describe "search selector" do
    it "should return the HTML for the selector with a default selected" do
      helper.search_selector(nil).should ==
%{<select id="st" name="st"><option value="m">matching</option>\n<option value="bw" selected="selected">beginning with</option>\n<option value="c">containing</option></select>}
    end
    it "should return the HTML for the selector with the specified one selected" do
      helper.search_selector('c').should ==
%{<select id="st" name="st"><option value="m">matching</option>\n<option value="bw">beginning with</option>\n<option value="c" selected="selected">containing</option></select>}
    end
  end

  describe "Delegation to Formatters::CatalogFormatter" do
    it "status labels" do
      Formatters::CatalogFormatter.should_receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      Formatters::CatalogFormatter.should_receive(:format_statistics).with(1, :include_invalid => true)
      helper.format_statistics 1, true
    end
  end

  describe "Hide link" do
    it "should create a link to the hide tribes action with all the current parameters" do
      taxon = FactoryGirl.create :genus
      helper.hide_link('tribes', taxon, {}).should == '<a href="/catalog/hide_tribes">hide</a>'
    end
  end

  describe "Show child link" do
    it "should create a link to the show action" do
      taxon = FactoryGirl.create :genus
      helper.show_child_link('tribes', taxon, {}).should == %{<a href="/catalog/show_tribes">show tribes</a>}
    end
  end

  describe "Delegation to Formatters::CatalogFormatter" do
    it "status labels" do
      Formatters::CatalogFormatter.should_receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      Formatters::CatalogFormatter.should_receive(:format_statistics).with(1, include_invalid: true)
      helper.format_statistics 1, true
    end
  end

  describe "Index column link" do
    it "should work" do
      helper.index_column_link(:subfamily, 'none', 'none', nil).should == '<a href="/catalog?child=none" class="valid selected">(no subfamily)</a>'
    end
  end

end
