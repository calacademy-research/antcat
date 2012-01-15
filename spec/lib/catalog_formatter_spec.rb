# coding: UTF-8
require 'spec_helper'

describe CatalogFormatter do
  before do
    @formatter = CatalogFormatter
  end

  describe "The new world order" do

    describe "Headline formatting" do
      it "should format the taxon name" do
        protonym = Factory :protonym, :name => 'Atari'
        atta = Factory :genus, :name => 'Atta', :protonym => protonym
        @formatter.format_headline_name(atta).should == '<span class="family_group_name">Atari</span>'
      end
      it "should handle the special taxon 'no_tribe'" do
        @formatter.format_headline_name('no_tribe').should be_blank
      end
      it "should handle the special taxon 'no_subfamily'" do
        @formatter.format_headline_name('no_subfamily').should be_blank
      end
      it "should handle nil" do
        @formatter.format_headline_name(nil).should be_blank
      end

      describe "Type" do
        it "should show the type taxon" do
          species = Factory :species, :name => 'major'
          genus = Factory :genus, :name => 'Atta', :type_taxon => species
          species.update_attribute :genus, genus
          @formatter.format_headline_type(genus).should ==
%{<span class="type">Type-species: <span class="species name taxon">Atta major</span>.</span>}
        end
        it "should show the type taxon with extra Taxt" do
          species = Factory :species, :name => 'major'
          genus = Factory :genus, :name => 'Atta', :type_taxon => species, :type_taxon_taxt => ', by monotypy'
          species.update_attribute :genus, genus
          @formatter.format_headline_type(genus).should ==
%{<span class="type">Type-species: <span class="species name taxon">Atta major</span>, by monotypy.</span>}
        end
      end
    end

    describe "Taxonomic history" do
      before do
        @taxon = Factory :family
      end
      describe "Taxonomic history formatting" do
        it "should format a number of items together in order" do
          @taxon.taxonomic_history_items.create! :taxt => 'Ant'
          @taxon.taxonomic_history_items.create! :taxt => 'Taxonomy'
          @formatter.format_taxonomic_history(@taxon, nil).should ==
            '<div class="taxonomic_history_item">Ant.</div>' +
            '<div class="taxonomic_history_item">Taxonomy.</div>'
        end
      end
      describe "Taxonomic history item formatting" do
        it "should format a phrase" do
          @formatter.format_taxonomic_history_item('phrase', nil).should == '<div class="taxonomic_history_item">phrase.</div>'
        end
        it "should format a ref" do
          reference = Factory :article_reference
          ReferenceFormatter.should_receive(:format_interpolation).with(reference, nil).and_return 'foo'
          @formatter.format_taxonomic_history_item("{ref #{reference.id}}", nil).should == '<div class="taxonomic_history_item">foo.</div>'
        end
        it "should not freak if the ref is malformed" do
          @formatter.format_taxonomic_history_item("{ref sdf}", nil).should == '<div class="taxonomic_history_item">{ref sdf}.</div>'
        end
        it "should not freak if the ref points to a reference that doesn't exist" do
          @formatter.format_taxonomic_history_item("{ref 12345}", nil).should == '<div class="taxonomic_history_item">{ref 12345}.</div>'
        end
      end
    end

    describe "PDF link formatting" do
      it "should create a link" do
        reference = Factory :reference
        reference.stub(:downloadable_by?).and_return true
        reference.stub(:url).and_return 'example.com'
        @formatter.format_reference_document_link(reference, nil).should == '<a class="document_link" target="_blank" href="example.com">PDF</a>'
      end
    end

  end

  describe 'Taxon statistics' do
    it "should get the statistics, then format them" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return :extant => :foo
      @formatter.should_receive(:format_statistics).with({:extant => :foo}, {})
      @formatter.format_taxon_statistics subfamily
    end
    it "should just return nil if there are no statistics" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return nil
      @formatter.should_not_receive(:format_statistics)
      @formatter.format_taxon_statistics(subfamily).should == ''
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = Factory :genus, :taxonomic_history => 'foo'
      genus.should_receive(:statistics).and_return :extant => {:species => {'valid' => 2}}
      @formatter.format_taxon_statistics(genus, :include_invalid => false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = Factory :genus, :taxonomic_history => 'foo'
      genus.should_receive(:statistics).and_return :extant => {:species => {'valid' => 2}}
      @formatter.format_taxon_statistics(genus, :include_invalid => false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end
  end

  describe 'Formatting statistics' do
    it "handle nil and {}" do
      @formatter.format_statistics(nil).should == ''
      @formatter.format_statistics({}).should == ''
    end
    it "should use commas in numbers" do
      @formatter.format_statistics(:extant => {:genera => {'valid' => 2_000}}).should == '<p class="taxon_statistics">2,000 valid genera</p>'
    end
    it "should use commas in numbers when not showing invalid" do
      @formatter.format_statistics({:extant => {:genera => {'valid' => 2_000}}}, :include_invalid => false).should == '<p class="taxon_statistics">2,000 genera</p>'
    end
    it "should handle both extant and fossil statistics" do
      statistics = {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should ==
"<p class=\"taxon_statistics\">Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>" +
"<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end
    it "should not include fossil statistics if not desired" do
      statistics = {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics, :include_fossil => false).should ==
        "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end
    it "should handle just fossil statistics" do
      statistics = {
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end

    it "should handle both extant and fossil statistics" do
      statistics = {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should ==
"<p class=\"taxon_statistics\">Extant: 1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>" +
"<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end
    it "should not include fossil statistics if not desired" do
      statistics = {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics, :include_fossil => false).should ==
        "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end
    it "should handle just fossil statistics" do
      statistics = {
        :fossil => {:subfamilies => {'valid' => 2}},
      }
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">Fossil: 2 valid subfamilies</p>"
    end

    it "should format the family's statistics correctly" do
      statistics = {:extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">1 valid subfamily, 2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end

    it "should format a subfamily's statistics correctly" do
      statistics = {:extant => {:genera => {'valid' => 2, 'synonym' => 1, 'homonym' => 2}, :species => {'valid' => 1}}}
      @formatter.format_statistics(statistics).should == "<p class=\"taxon_statistics\">2 valid genera (1 synonym, 2 homonyms), 1 valid species</p>"
    end

    it "should use the singular for genus" do
      @formatter.format_statistics(:extant => {:genera => {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid genus</p>"
    end

    it "should format a genus's statistics correctly" do
      @formatter.format_statistics(:extant => {:species => {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid species</p>"
    end

    it "should format a species's statistics correctly" do
      @formatter.format_statistics(:extant => {:subspecies => {'valid' => 1}}).should == "<p class=\"taxon_statistics\">1 valid subspecies</p>"
    end

    it "should handle when there are no valid rank members" do
      species = Factory :species
      Factory :subspecies, :species => species, :status => 'synonym'
      @formatter.format_statistics(:extant => {:subspecies => {'synonym' => 1}}).should == "<p class=\"taxon_statistics\">(1 synonym)</p>"
    end

    it "should not pluralize certain statuses" do
      @formatter.format_statistics(:extant => {:species => {'valid' => 2, 'synonym' => 2, 'homonym' => 2, 'unavailable' => 2, 'unidentifiable' => 2, 'excluded' => 2, 'unresolved homonym' => 2, 'nomen nudum' => 2}}).should == "<p class=\"taxon_statistics\">2 valid species (2 synonyms, 2 homonyms, 2 unavailable, 2 unidentifiable, 2 excluded, 2 unresolved homonyms, 2 nomina nuda)</p>"
    end

    it "should leave out invalid status if desired" do
      @formatter.format_statistics({:extant => {:genera => {'valid' => 1, 'homonym' => 2}, :species => {'valid' => 2}, :subspecies => {'valid' => 3}}}, :include_invalid => false).should == "<p class=\"taxon_statistics\">1 genus, 2 species, 3 subspecies</p>"
    end

    it "should not leave a trailing comma" do
      @formatter.format_statistics({:extant => {:species => {'valid' => 2}}}, :include_fossil => false, :include_invalid => false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end

    it "should not leave a trailing comma" do
      @formatter.format_statistics({:extant => {:species => {'valid' => 2}}}, :include_fossil => false, :include_invalid => false).should == "<p class=\"taxon_statistics\">2 species</p>"
    end

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

  describe "Pluralizing with commas" do
    it "should handle a single item" do
      @formatter.pluralize_with_delimiters(1, 'bear').should == '1 bear'
    end
    it "should handle two items" do
      @formatter.pluralize_with_delimiters(2, 'bear').should == '2 bears'
    end
    it "should use the provided plural" do
      @formatter.pluralize_with_delimiters(2, 'genus', 'genera').should == '2 genera'
    end
    it "should use commas" do
      @formatter.pluralize_with_delimiters(2000, 'bear').should == '2,000 bears'
    end
  end

end
