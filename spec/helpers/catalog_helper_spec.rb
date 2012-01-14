# coding: UTF-8
require 'spec_helper'

describe CatalogHelper do

  describe "Taxon link" do
    describe "(no subfamily)" do
      it "should format the '(no subfamily)' link" do
        taxon_link(:subfamily, 'none', nil).should ==
  %{<a href="/catalog/index?subfamily=none" class="valid">(no subfamily)</a>}
      end
      it "should format the '(no subfamily)' link when selected" do
        taxon_link(:subfamily, 'none', 'none').should ==
  %{<a href="/catalog/index?subfamily=none" class="valid selected">(no subfamily)</a>}
      end
    end
    describe "subfamily" do
      it "should format a subfamily link" do
        selected_subfamily = Factory :subfamily, :name => 'Formicinae'
        subfamily = Factory :subfamily, :name => 'Dolichoderinae'
        taxon_link(:subfamily, subfamily, selected_subfamily).should ==
  %{<a href="/catalog/index/#{subfamily.id}?subfamily=#{subfamily.id}" class="subfamily taxon valid">Dolichoderinae</a>}
      end
      it "should format a selected subfamily link" do
        subfamily = Factory :subfamily, :name => 'Dolichoderinae'
        taxon_link(:subfamily, subfamily, subfamily, :subfamily => subfamily).should ==
  %{<a href="/catalog/index/#{subfamily.id}?subfamily=#{subfamily.id}" class="selected subfamily taxon valid">Dolichoderinae</a>}
      end
    end
    describe "genus" do
      it "should format a genus link" do
        genus = Factory :genus, :name => 'Atta'
        taxon_link(:genus, genus, nil, :genus => genus).should ==
  %{<a href="/catalog/index/#{genus.id}?genus=#{genus.id}" class="genus taxon valid">Atta</a>}
      end
    end
    describe "tribe" do
      it "should format a tribe link" do
        tribe = Factory :tribe, :name => 'Atta'
        subfamily = tribe.subfamily
        taxon_link(:tribe, tribe, nil, :subfamily => subfamily).should ==
  %{<a href="/catalog/index/#{tribe.id}?subfamily=#{subfamily.id}&amp;tribe=#{tribe.id}" class="taxon tribe valid">Atta</a>}
      end
    end
  end

  describe 'taxon header' do
    it "should return the header and CSS class based on the type of the taxon, its status and whether or not it's a fossil" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      taxon_header = helper.taxon_header taxon, :link => true
      taxon_header.should ==
        %{Genus <a href="#{browser_catalog_path taxon}" class="genus taxon valid">&dagger;ATTA</a>}
      taxon_header.should be_html_safe
    end
    it "should be able to not include a link" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      taxon_header = helper.taxon_header taxon
      taxon_header.should ==
        %{Genus <span class="genus taxon valid">&dagger;ATTA</span>}
      taxon_header.should be_html_safe
    end
  end

  describe 'Grouping index items' do
    it "should just return the items if the number of rows isn't exceeded" do
      a = Factory :species, :name => 'a'
      b = Factory :species, :name => 'b'
      helper.make_index_groups([a,b], 2, 4).should == [
        {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
        {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
    end
    it "should sort the items" do
      a = Factory :species, :name => 'a'
      b = Factory :species, :name => 'b'
      helper.make_index_groups([b,a], 2, 4).should == [
        {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
        {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
    end
    it "should create groups of items" do
      a = Factory :species, :name => 'a'
      b = Factory :species, :name => 'b'
      c = Factory :species, :name => 'c'
      helper.make_index_groups([a,b,c], 2, 4).should == [
        {:label => 'a-b', :id => a.id, :css_classes => 'species taxon'},
        {:label => 'c', :id => c.id, :css_classes => 'species taxon'}]
    end
    it "should abbreviate items" do
      a = Factory :species, :name => 'Acanthomyrmex'
      b = Factory :species, :name => 'Atta'
      c = Factory :species, :name => 'Tetramorium'
      helper.make_index_groups([a,b,c], 2, 4).should == [
        {:label => 'Acan-Atta', :id => a.id, :css_classes => 'species taxon'},
        {:label => 'Tetramorium', :id => c.id, :css_classes => 'species taxon'}]
    end
    it "should prepend daggers on single items" do
      a = Factory :species, :name => 'Acanthomyrmex', :fossil => true
      helper.make_index_groups([a], 2, 4).should == [{:label => '&dagger;Acanthomyrmex', :id => a.id, :css_classes => 'species taxon valid'}]
    end
    it "should not have a cow if there are no items" do
      helper.make_index_groups([], 2, 4).should == []
    end
  end

  describe "search selector" do
    it "should return the HTML for the selector with a default selected" do
      helper.search_selector(nil).should == 
%{<select id="search_type" name="search_type"><option value="matching">matching</option>\n<option value="beginning with" selected="selected">beginning with</option>\n<option value="containing">containing</option></select>}
    end
    it "should return the HTML for the selector with the specified one selected" do
      helper.search_selector('containing').should == 
%{<select id="search_type" name="search_type"><option value="matching">matching</option>\n<option value="beginning with">beginning with</option>\n<option value="containing" selected="selected">containing</option></select>}
    end
  end

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
