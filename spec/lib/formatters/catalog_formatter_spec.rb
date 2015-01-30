# coding: UTF-8
require 'spec_helper'

describe Formatters::CatalogFormatter do
  before do
    @formatter = Formatters::CatalogFormatter
  end

  describe "Taxon label span" do
    it "should create a span based on the type of the taxon and its status" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      result = @formatter.taxon_label_span(taxon)
      expect(result).to eq('<span class="genus name taxon valid">Atta</span>')
      expect(result).to be_html_safe
    end
  end

  describe 'taxon label and css classes' do
    it "should return the CSS class based on the type of the taxon and its status" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      taxon_label_and_css_classes = @formatter.taxon_label_and_css_classes(taxon)
      expect(taxon_label_and_css_classes[:label]).to eq('Atta')
      expect(taxon_label_and_css_classes[:css_classes]).to eq('genus name taxon valid')
    end
    it "should prepend a fossil symbol" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :fossil => true
      expect(@formatter.taxon_label_and_css_classes(taxon)[:label]).to eq('&dagger;Atta')
    end
    it "should handle being selected" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      expect(@formatter.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes]).to eq('genus name selected taxon valid')
    end
    it "should handle upper case" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      expect(@formatter.taxon_label_and_css_classes(taxon, :uppercase => true)[:label]).to eq('ATTA')
    end
    it "should return an HTML safe label" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      expect(@formatter.taxon_label_and_css_classes(taxon)[:label]).to be_html_safe
    end
  end

  describe 'taxon rank css classes' do
    it 'should return the right ones' do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      expect(@formatter.css_classes_for_rank(taxon)).to match_array(['genus', 'taxon', 'name'])
    end
  end

  describe 'taxon class' do
    it "should return the correct classes" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      expect(@formatter.taxon_css_classes(taxon)).to eq("genus name taxon valid")
    end
  end

  describe "PDF link formatting" do
    it "should create a link" do
      reference = FactoryGirl.create :reference
      allow(reference).to receive(:downloadable_by?).and_return true
      allow(reference).to receive(:url).and_return 'example.com'
      expect(@formatter.format_reference_document_link(reference, nil)).to eq('<a class="document_link" href="example.com" target="_blank">PDF</a>')
    end
  end


end
