# coding: UTF-8
require 'spec_helper'

describe CatalogFormatter do
  before do
    @formatter = CatalogFormatter
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

end
