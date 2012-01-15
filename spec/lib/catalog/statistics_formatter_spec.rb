# coding: UTF-8
require 'spec_helper'

describe CatalogFormatter do
  before do
    @formatter = CatalogFormatter
  end

  describe 'Taxon statistics' do
    it "should get the statistics, then format them" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return extant: :foo
      @formatter.should_receive(:format_statistics).with({extant: :foo}, {})
      @formatter.format_taxon_statistics subfamily
    end
    it "should just return nil if there are no statistics" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return nil
      @formatter.should_not_receive(:format_statistics)
      @formatter.format_taxon_statistics(subfamily).should == ''
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = Factory :genus, taxonomic_history: 'foo'
      genus.should_receive(:statistics).and_return extant: {species: {'valid' => 2}}
      @formatter.format_taxon_statistics(genus, include_invalid: false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = Factory :genus, taxonomic_history: 'foo'
      genus.should_receive(:statistics).and_return extant: {species: {'valid' => 2}}
      @formatter.format_taxon_statistics(genus, include_invalid: false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end
  end

  describe 'Formatting statistics' do
    it "handle nil and {}" do
      @formatter.format_statistics(nil).should == ''
      @formatter.format_statistics({}).should == ''
    end
    it "should use commas in numbers" do
      @formatter.format_statistics(extant: {genera: {'valid' => 2_000}}).should == '<p class="taxon_statistics">2,000 valid genera</p>'
    end
    it "should use commas in numbers when not showing invalid" do
      @formatter.format_statistics({extant: {genera: {'valid' => 2_000}}}, include_invalid: false).should == '<p class="taxon_statistics">2,000 genera</p>'
    end
    it "should handle both extant and fossil statistics" do
      statistics = {
        extant: {subfamilies: {'valid' => 1}, genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}},
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should ==
"<p class=\"taxon_statistics\">Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>" +
"<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end
    it "should not include fossil statistics if not desired" do
      statistics = {
        extant: {subfamilies: {'valid' => 1}, genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}},
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics, include_fossil: false).should ==
        "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end
    it "should handle just fossil statistics" do
      statistics = {
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end

    it "should handle both extant and fossil statistics" do
      statistics = {
        extant: {subfamilies: {'valid' => 1}, genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}},
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should ==
"<p class=\"taxon_statistics\">Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>" +
"<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end
    it "should not include fossil statistics if not desired" do
      statistics = {
        extant: {subfamilies: {'valid' => 1}, genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}},
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics, include_fossil: false).should ==
        "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end
    it "should handle just fossil statistics" do
      statistics = {
        fossil: {subfamilies: {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end

    it "should format the family's statistics correctly" do
      statistics = {extant: {subfamilies: {'valid' => 1}, genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end

    it "should format a subfamily's statistics correctly" do
      statistics = {extant: {genera: {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, species: {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end

    it "should use the singular for genus" do
      @formatter.format_statistics(extant: {genera: {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid genus</p>"
    end

    it "should format a genus's statistics correctly" do
      @formatter.format_statistics(extant: {species: {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid species</p>"
    end

    it "should format a species's statistics correctly" do
      @formatter.format_statistics(extant: {subspecies: {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid subspecies</p>"
    end

    it "should handle when there are no valid rank members" do
      species = Factory :species
      Factory :subspecies, species: species, status: 'synonym'
      @formatter.format_statistics(extant: {subspecies: {'synonym' => 1}}).should == "<p class=\"taxon_statistics\">(1 synonym)</p>"
    end

    it "should not pluralize certain statuses" do
      @formatter.format_statistics(extant: {species: {'valid' => 2, 'synonym' => 2, 'homonym' => 2, 'unavailable' => 2, 'unidentifiable' => 2, 'excluded' => 2, 'unresolved homonym' => 2, 'nomen nudum' => 2}}).should == "<p class=\"taxon_statistics\">2 valid species (2 synonyms, 2 homonyms, 2 unavailable, 2 unidentifiable, 2 excluded, 2 unresolved homonyms, 2 nomina nuda)</p>"
    end

    it "should leave out invalid status if desired" do
      @formatter.format_statistics({extant: {genera: {'valid' => 1, 'homonym' => 2}, species: {'valid' => 2}, subspecies: {'valid' => 3}}}, include_invalid: false).should == "<p class=\"taxon_statistics\">1 genus, 2 species, 3 subspecies</p>"
    end

    it "should not leave a trailing comma" do
      @formatter.format_statistics({extant: {species: {'valid' => 2}}}, include_fossil: false, include_invalid: false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end

    it "should not leave a trailing comma" do
      @formatter.format_statistics({extant: {species: {'valid' => 2}}}, include_fossil: false, include_invalid: false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end

  end
end
