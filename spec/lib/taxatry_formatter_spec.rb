require 'spec_helper'

describe TaxatryFormatter do

  describe "taxonomic history" do
    
    describe 'Simple' do
      it "should return the field" do
        genus = Factory :genus, :taxonomic_history => 'foo'
        TaxatryFormatter.format_taxonomic_history(genus).should == 'foo'
      end
    end

    describe 'With homonyms' do
      it "should return the field + the list of homonyms" do
        replacement = Factory :genus, :name => 'Dlusskyidris', :taxonomic_history => '<p>Dlusskyidris history</p>', :fossil => true
        junior_homonym = Factory :genus, :name => 'Palaeomyrmex', :taxonomic_history => '<p>Palaeomyrmex history</p>', :status => 'homonym', :homonym_replaced_by => replacement
        TaxatryFormatter.format_taxonomic_history(replacement).should == 
  %{<p>Dlusskyidris history</p>} + 
  %{<p class="taxon_subsection_header">Homonym replaced by <span class="genus taxon valid">&dagger;DLUSSKYIDRIS</span></p>} +
  %{<div id="#{junior_homonym.id}"><p>Palaeomyrmex history</p></div>}
      end
    end

  end

  describe 'taxon label and css classes' do

    it "should return the CSS class based on the type of the taxon and its status" do
      taxon = Factory :genus, :name => 'Atta'
      taxon_label_and_css_classes = TaxatryFormatter.taxon_label_and_css_classes(taxon)
      taxon_label_and_css_classes[:label].should == 'Atta'
      taxon_label_and_css_classes[:css_classes].should == 'genus taxon valid'
    end

    it "should prepend a fossil symbol" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      TaxatryFormatter.taxon_label_and_css_classes(taxon)[:label].should == '&dagger;Atta'
    end

    it "should handle being selected" do
      taxon = Factory :genus, :name => 'Atta'
      TaxatryFormatter.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes].should == 'genus selected taxon valid'
    end

    it "should handle upper case" do
      taxon = Factory :genus, :name => 'Atta'
      TaxatryFormatter.taxon_label_and_css_classes(taxon, :uppercase => true)[:label].should == 'ATTA'
    end

    it "should return an HTML safe label" do
      taxon = Factory :genus, :name => 'Atta'
      TaxatryFormatter.taxon_label_and_css_classes(taxon)[:label].should be_html_safe
    end

  end

  describe 'taxon rank css classes' do
    it 'should return the right ones' do
      taxon = Factory :genus, :name => 'Atta'
      TaxatryFormatter.css_classes_for_rank(taxon).should == ['genus', 'taxon']
    end
  end

  describe 'taxon class' do
    it "should return the correct classes" do
      taxon = Factory :genus, :name => 'Atta'
      TaxatryFormatter.css_classes_for_taxon(taxon).should == "genus taxon valid"
    end
  end

end
