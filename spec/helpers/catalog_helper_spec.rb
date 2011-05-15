require 'spec_helper'

describe CatalogHelper do

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

  describe 'Statistics' do

    it "should format a subfamily's statistics correctly" do
      subfamily = Factory :subfamily
      Factory :genus, :subfamily => subfamily
      Factory :genus, :subfamily => subfamily
      genus = Factory :genus, :subfamily => subfamily, :status => 'synonym'
      2.times {Factory :genus, :subfamily => subfamily, :status => 'homonym'}
      Factory :species, :genus => genus
      helper.taxon_statistics(subfamily).should == "2 valid genera (1 synonym, 2 homonyms), 1 valid species"
    end

    it "should use the singular for genus" do
      subfamily = Factory :subfamily
      Factory :genus, :subfamily => subfamily
      helper.taxon_statistics(subfamily).should == "1 valid genus"
    end

    it "should format a genus's statistics correctly" do
      genus = Factory :genus
      Factory :species, :genus => genus
      helper.taxon_statistics(genus).should == "1 valid species"
    end

    it "should format a species's statistics correctly" do
      species = Factory :species
      Factory :subspecies, :species => species
      helper.taxon_statistics(species).should == "1 valid subspecies"
    end

    it "should handle when there are no valid rank members" do
      species = Factory :species
      Factory :subspecies, :species => species, :status => 'synonym'
      helper.taxon_statistics(species).should == "(1 synonym)"
    end

    it "should not pluralize certain statuses" do
      genus = Factory :genus
      2.times {Factory :species, :genus => genus, :status => 'valid'}
      2.times {Factory :species, :genus => genus, :status => 'synonym'}
      2.times {Factory :species, :genus => genus, :status => 'homonym'}
      2.times {Factory :species, :genus => genus, :status => 'unavailable'}
      2.times {Factory :species, :genus => genus, :status => 'unidentifiable'}
      2.times {Factory :species, :genus => genus, :status => 'excluded'}
      2.times {Factory :species, :genus => genus, :status => 'unresolved homonym'}
      2.times {Factory :species, :genus => genus, :status => 'nomen nudum'}
      helper.taxon_statistics(genus).should == "2 valid species (2 synonyms, 2 homonyms, 2 unavailable, 2 unidentifiable, 2 excluded, 2 unresolved homonyms, 2 nomina nuda)"
    end

  end

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      helper.status_labels['synonym'][:singular].should == 'synonym'
      helper.status_labels['synonym'][:plural].should == 'synonyms'
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
end
