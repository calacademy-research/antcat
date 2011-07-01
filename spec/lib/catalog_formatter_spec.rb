require 'spec_helper'

describe CatalogFormatter do
  before do
    @formatter = CatalogFormatter
  end

  describe 'Taxon statistics' do
    it "should get the statistics, then format them" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return :extant => :foo
      @formatter.should_receive(:format_statistics).with({:extant => :foo}, true)
      @formatter.taxon_statistics(subfamily)
    end
    it "should just return nil if there are no statistics" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return nil
      @formatter.should_not_receive(:format_statistics)
      @formatter.taxon_statistics(subfamily).should be_nil
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = Factory :genus, :taxonomic_history => 'foo'
      genus.should_receive(:statistics).and_return :extant => {:species => {'valid' => 2}}
      @formatter.taxon_statistics(genus, false, false).should == "2 species"
    end
  end

  describe 'Formatting statistics' do
    it "handle nil" do
      @formatter.format_statistics(nil).should be_nil
    end

    it "should handle both extant and fossil statistics" do
      statistics = {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == [
        "Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species",
        "Fossil: 2 valid subfamilies",
      ]
    end
    it "should handle just fossil statistics" do
      statistics = {
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == "Fossil: 2 valid subfamilies"
    end

    it "should format the family's statistics correctly" do
      statistics = {:extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species"
    end

    it "should format a subfamily's statistics correctly" do
      statistics = {:extant => {:genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "2 valid genera (1 synonym, 2 homonyms), 1 valid species"
    end

    it "should use the singular for genus" do
      @formatter.format_statistics(:extant => {:genera => {'valid' => 1}}).should == "1 valid genus"
    end

    it "should format a genus's statistics correctly" do
      @formatter.format_statistics(:extant => {:species => {'valid' => 1}}).should == "1 valid species"
    end

    it "should format a species's statistics correctly" do
      @formatter.format_statistics(:extant => {:subspecies => {'valid' => 1}}).should == "1 valid subspecies"
    end

    it "should handle when there are no valid rank members" do
      species = Factory :species
      Factory :subspecies, :species => species, :status => 'synonym'
      @formatter.format_statistics(:extant => {:subspecies => {'synonym' => 1}}).should == "(1 synonym)"
    end

    it "should not pluralize certain statuses" do
      @formatter.format_statistics(:extant => {:species => {'valid' => 2, 'synonym' => 2, 'homonym' => 2, 'unavailable' => 2, 'unidentifiable' => 2, 'excluded' => 2, 'unresolved homonym' => 2, 'nomen nudum' => 2}}).should == "2 valid species (2 synonyms, 2 homonyms, 2 unavailable, 2 unidentifiable, 2 excluded, 2 unresolved homonyms, 2 nomina nuda)"
    end

    it "should leave out invalid status if desired" do
      @formatter.format_statistics({:extant => {:genera => {'valid' => 1, 'homonym' => 2}, :species => {'valid' => 2}, :subspecies => {'valid' => 3}}}, false).should == "1 genus, 2 species, 3 subspecies"
    end

    it "should not leave a trailing comma" do
      @formatter.format_statistics({:extant => {:species => {'valid' => 2}}}, false).should == "2 species"
    end

  end

  describe "taxonomic history" do
    
    describe 'Simple' do
      it "should return the field" do
        genus = Factory :genus, :taxonomic_history => 'foo'
        @formatter.format_taxonomic_history(genus).should == 'foo'
      end
    end

    describe 'With homonyms' do
      it "should return the field + the list of homonyms" do
        replacement = Factory :genus, :name => 'Dlusskyidris', :taxonomic_history => '<p>Dlusskyidris history</p>', :fossil => true
        junior_homonym = Factory :genus, :name => 'Palaeomyrmex', :taxonomic_history => '<p>Palaeomyrmex history</p>', :status => 'homonym', :homonym_replaced_by => replacement
        @formatter.format_taxonomic_history(replacement).should == 
  %{<p>Dlusskyidris history</p>} + 
  %{<p class="taxon_subsection_header">Homonym replaced by <span class="genus taxon valid">&dagger;DLUSSKYIDRIS</span></p>} +
  %{<div id="#{junior_homonym.id}"><p>Palaeomyrmex history</p></div>}
      end
    end

    describe "Formatting taxonomic history with statistics" do
      it "should handle a simple case" do
        taxon = Factory :subfamily, :taxonomic_history => '<p>Taxonomic history</p>'
        taxon.should_receive(:statistics).and_return(:extant => {:genera => {'valid' => 1, 'homonym' => 2}, :species => {'valid' => 2}, :subspecies => {'valid' => 3}})
        @formatter.format_taxonomic_history_with_statistics(taxon).should == '<p class="taxon_statistics">1 genus, 2 species, 3 subspecies</p><p>Taxonomic history</p>'
      end
      it "should handle an even simpler case" do
        taxon = Factory :subfamily, :taxonomic_history => '<p>Taxonomic history</p>'
        taxon.should_receive(:statistics).and_return(:extant => {:genera => {'valid' => 1}, :species => {'valid' => 0}, :subspecies => {'valid' => 3}})
        @formatter.format_taxonomic_history_with_statistics(taxon).should == '<p class="taxon_statistics">1 genus, 0 species, 3 subspecies</p><p>Taxonomic history</p>'
      end
      it "should just return the taxonomic history alone for a subspecies" do
        taxon = Factory :subspecies, :taxonomic_history => 'history'
        @formatter.format_taxonomic_history_with_statistics(taxon).should == 'history'
      end
    end

  end

  describe 'taxon label and css classes' do

    it "should return the CSS class based on the type of the taxon and its status" do
      taxon = Factory :genus, :name => 'Atta'
      taxon_label_and_css_classes = @formatter.taxon_label_and_css_classes(taxon)
      taxon_label_and_css_classes[:label].should == 'Atta'
      taxon_label_and_css_classes[:css_classes].should == 'genus taxon valid'
    end

    it "should prepend a fossil symbol" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      @formatter.taxon_label_and_css_classes(taxon)[:label].should == '&dagger;Atta'
    end

    it "should handle being selected" do
      taxon = Factory :genus, :name => 'Atta'
      @formatter.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes].should == 'genus selected taxon valid'
    end

    it "should handle upper case" do
      taxon = Factory :genus, :name => 'Atta'
      @formatter.taxon_label_and_css_classes(taxon, :uppercase => true)[:label].should == 'ATTA'
    end

    it "should return an HTML safe label" do
      taxon = Factory :genus, :name => 'Atta'
      @formatter.taxon_label_and_css_classes(taxon)[:label].should be_html_safe
    end

  end

  describe 'taxon rank css classes' do
    it 'should return the right ones' do
      taxon = Factory :genus, :name => 'Atta'
      @formatter.css_classes_for_rank(taxon).should == ['genus', 'taxon']
    end
  end

  describe 'taxon class' do
    it "should return the correct classes" do
      taxon = Factory :genus, :name => 'Atta'
      @formatter.css_classes_for_taxon(taxon).should == "genus taxon valid"
    end
  end

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      @formatter.status_labels['synonym'][:singular].should == 'synonym'
      @formatter.status_labels['synonym'][:plural].should == 'synonyms'
    end
  end

end
