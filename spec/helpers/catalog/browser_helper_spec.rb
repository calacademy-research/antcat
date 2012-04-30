# coding: UTF-8
require 'spec_helper'

describe Catalog::BrowserHelper do

  describe 'taxon header' do
    #it "should return the header and CSS class based on the type of the taxon, its status and whether or not it's a fossil" do
      #taxon = FactoryGirl.create :genus, :name => 'Atta', :fossil => true
      #taxon_header = helper.browser_taxon_header taxon, :link => true
      #taxon_header.should ==
        #%{Genus <a href="#{browser_catalog_path taxon}" class="genus taxon valid">&dagger;ATTA</a>}
      #taxon_header.should be_html_safe
    #end
    it "should be able to not include a link" do
      taxon = FactoryGirl.create :genus, :name => 'Atta', :fossil => true
      taxon_header = helper.browser_taxon_header taxon
      taxon_header.should ==
        %{Genus <span class="genus taxon valid">&dagger;ATTA</span>}
      taxon_header.should be_html_safe
    end
  end

  describe 'Grouping index items' do
    it "should just return the items if the number of rows isn't exceeded" do
      a = FactoryGirl.create :species, :name => 'a'
      b = FactoryGirl.create :species, :name => 'b'
      helper.make_index_groups([a,b], 2, 4).should == [
        {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
        {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
    end
    it "should sort the items" do
      a = FactoryGirl.create :species, :name => 'a'
      b = FactoryGirl.create :species, :name => 'b'
      helper.make_index_groups([b,a], 2, 4).should == [
        {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
        {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
    end
    it "should create groups of items" do
      a = FactoryGirl.create :species, :name => 'a'
      b = FactoryGirl.create :species, :name => 'b'
      c = FactoryGirl.create :species, :name => 'c'
      helper.make_index_groups([a,b,c], 2, 4).should == [
        {:label => 'a-b', :id => a.id, :css_classes => 'species taxon'},
        {:label => 'c', :id => c.id, :css_classes => 'species taxon'}]
    end
    it "should abbreviate items" do
      a = FactoryGirl.create :species, :name => 'Acanthomyrmex'
      b = FactoryGirl.create :species, :name => 'Atta'
      c = FactoryGirl.create :species, :name => 'Tetramorium'
      helper.make_index_groups([a,b,c], 2, 4).should == [
        {:label => 'Acan-Atta', :id => a.id, :css_classes => 'species taxon'},
        {:label => 'Tetramorium', :id => c.id, :css_classes => 'species taxon'}]
    end
    it "should prepend daggers on single items" do
      a = FactoryGirl.create :species, :name => 'Acanthomyrmex', :fossil => true
      helper.make_index_groups([a], 2, 4).should == [{:label => '&dagger;Acanthomyrmex', :id => a.id, :css_classes => 'species taxon valid'}]
    end
    it "should not have a cow if there are no items" do
      helper.make_index_groups([], 2, 4).should == []
    end
  end

end
