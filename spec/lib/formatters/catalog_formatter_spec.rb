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
      result.should == '<span class="genus name taxon valid">Atta</span>'
      result.should be_html_safe
    end
  end

  describe 'taxon label and css classes' do
    it "should return the CSS class based on the type of the taxon and its status" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      taxon_label_and_css_classes = @formatter.taxon_label_and_css_classes(taxon)
      taxon_label_and_css_classes[:label].should == 'Atta'
      taxon_label_and_css_classes[:css_classes].should == 'genus name taxon valid'
    end
    it "should prepend a fossil symbol" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :fossil => true
      @formatter.taxon_label_and_css_classes(taxon)[:label].should == '&dagger;Atta'
    end
    it "should handle being selected" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      @formatter.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes].should == 'genus name selected taxon valid'
    end
    it "should handle upper case" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      @formatter.taxon_label_and_css_classes(taxon, :uppercase => true)[:label].should == 'ATTA'
    end
    it "should return an HTML safe label" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      @formatter.taxon_label_and_css_classes(taxon)[:label].should be_html_safe
    end
  end

  describe 'taxon rank css classes' do
    it 'should return the right ones' do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      @formatter.css_classes_for_rank(taxon).should =~ ['genus', 'taxon', 'name']
    end
  end

  describe 'taxon class' do
    it "should return the correct classes" do
      taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
      @formatter.taxon_css_classes(taxon).should == "genus name taxon valid"
    end
  end

  describe 'format_fossil' do
    it "should prepend a dagger" do
      @formatter.format_fossil('Atta', true).should == '&dagger;Atta'
      @formatter.format_fossil('Atta', false).should == 'Atta'
    end
  end

  describe "PDF link formatting" do
    it "should create a link" do
      reference = FactoryGirl.create :reference
      reference.stub(:downloadable_by?).and_return true
      reference.stub(:url).and_return 'example.com'
      @formatter.format_reference_document_link(reference, nil).should == '<a class="document_link" href="example.com" target="_blank">PDF</a>'
    end
  end


end
