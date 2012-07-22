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
    #it "should create a link with all the current parameters + hide_tribe => true" do
      #taxon = FactoryGirl.create :genus
      #helper.hide_link('tribes', taxon, {}).should == %{<a href="/catalog/#{taxon.id}?hide_tribes=true" class="hide">hide</a>}
    #end
  end

  describe "Show child link" do
    #it "if child is hidden, should create a link with all the current parameters and without hide_tribe" do
      #taxon = FactoryGirl.create :genus
      #helper.show_child_link('tribes', taxon, hide_tribes: true).should == %{<a href="/catalog/#{taxon.id}?hide_tribes=false">show tribes</a>}
    #end
    #it "if child is not hidden, return nil" do
      #taxon = FactoryGirl.create :genus
      #helper.show_child_link('tribes', taxon, {}).should be_nil
    #end
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

  describe "Making the 'Creating... message'" do
    it "should look like this" do
      helper.creating_taxon_message(:genus, FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Formicinae'))).should =~ /.*?ing genus .*? Formicinae/
    end
  end

  describe "Index column link" do
    it "should work" do
      helper.index_column_link(:subfamily, 'none', 'none', nil).should == '<a href="/catalog?child=none" class="valid selected">(no subfamily)</a>' 
    end
  end

end
