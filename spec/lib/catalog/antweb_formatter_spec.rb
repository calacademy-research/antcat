# coding: UTF-8
require 'spec_helper'

describe Catalog::AntwebFormatter do
  before do
    @formatter = CatalogFormatter
  end

  describe "taxonomic history" do
    
    describe 'Simple' do
      it "should return the field" do
        genus = Factory :genus, :taxonomic_history => 'foo'
        @formatter.format_taxonomic_history_for_antweb(genus).should == 'foo'
      end
    end

    describe 'With homonyms' do
      it "should return the field + the list of homonyms" do
        replacement = Factory :genus, :name => 'Dlusskyidris', :taxonomic_history => '<p>Dlusskyidris history</p>', :fossil => true
        junior_homonym = Factory :genus, :name => 'Palaeomyrmex', :taxonomic_history => '<p>Palaeomyrmex history</p>', :status => 'homonym', :homonym_replaced_by => replacement
        @formatter.format_taxonomic_history_for_antweb(replacement).should == 
  %{<p>Dlusskyidris history</p>} + 
  %{<p class="taxon_subsection_header">Homonym replaced by <span class="genus taxon valid">&dagger;DLUSSKYIDRIS</span></p>} +
  %{<div id="#{junior_homonym.id}"><p>Palaeomyrmex history</p></div>}
      end
    end

    describe "Formatting taxonomic history with statistics" do
      it "should handle a simple case" do
        taxon = Factory :subfamily, :taxonomic_history => '<p>Taxonomic history</p>'
        taxon.should_receive(:statistics).and_return(:extant => {:genera => {'valid' => 1, 'homonym' => 2}, :species => {'valid' => 2}, :subspecies => {'valid' => 3}})
        @formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false).should == '<p class="taxon_statistics">1 genus, 2 species, 3 subspecies</p><p>Taxonomic history</p>'
      end

      it "should handle a case with fossil and extant statistics" do
        taxon = Factory :subfamily, :taxonomic_history => '<p>Taxonomic history</p>'
        taxon.should_receive(:statistics).and_return(
          :extant => {:genera => {'valid' => 1, 'homonym' => 2}, :species => {'valid' => 2}, :subspecies => {'valid' => 3}},
          :fossil => {:genera => {'valid' => 3}}
        )
        @formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false).should ==
          '<p class="taxon_statistics">Extant: 1 genus, 2 species, 3 subspecies</p>' +
          '<p class="taxon_statistics">Fossil: 3 genera</p>' +
          '<p>Taxonomic history</p>'
      end

      it "should handle an even simpler case" do
        taxon = Factory :subfamily, :taxonomic_history => '<p>Taxonomic history</p>'
        taxon.should_receive(:statistics).and_return(:extant => {:genera => {'valid' => 1}, :species => {'valid' => 0}, :subspecies => {'valid' => 3}})
        @formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false).should == '<p class="taxon_statistics">1 genus, 0 species, 3 subspecies</p><p>Taxonomic history</p>'
      end

      it "should just return the taxonomic history alone for a subspecies" do
        taxon = Factory :subspecies, :taxonomic_history => 'history'
        @formatter.format_taxonomic_history_with_statistics_for_antweb(taxon).should == 'history'
      end
    end

  end
end
