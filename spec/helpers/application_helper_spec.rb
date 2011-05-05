require 'spec_helper'

describe ApplicationHelper do

  describe 'taxon header' do

    it "should return the header and CSS class based on the type of the taxon, its status and whether or not it's a fossil" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      taxon_header = helper.taxon_header(taxon)
      taxon_header.should ==
        %{Genus <a href="#{browser_taxatry_path taxon}" class="genus taxon valid">&dagger;ATTA</a>}
      taxon_header.should be_html_safe
    end

  end

  describe 'taxon class' do

    it "should return the correct classes" do
      taxon = Factory :genus, :name => 'Atta'
      helper.css_classes_for_taxon(taxon).should == "genus taxon valid"
    end

  end

  describe 'taxon label and css classes' do

    it "should return the CSS class based on the type of the taxon and its status" do
      taxon = Factory :genus, :name => 'Atta'
      taxon_label_and_css_classes = helper.taxon_label_and_css_classes(taxon)
      taxon_label_and_css_classes[:label].should == 'Atta'
      taxon_label_and_css_classes[:css_classes].should == 'genus taxon valid'
    end

    it "should prepend a fossil symbol" do
      taxon = Factory :genus, :name => 'Atta', :fossil => true
      helper.taxon_label_and_css_classes(taxon)[:label].should == '&dagger;Atta'
    end

    it "should handle being selected" do
      taxon = Factory :genus, :name => 'Atta'
      helper.taxon_label_and_css_classes(taxon, :selected => true)[:css_classes].should == 'genus selected taxon valid'
    end

    it "should handle upper case" do
      taxon = Factory :genus, :name => 'Atta'
      helper.taxon_label_and_css_classes(taxon, :uppercase => true)[:label].should == 'ATTA'
    end

    it "should return an HTML safe label" do
      taxon = Factory :genus, :name => 'Atta'
      helper.taxon_label_and_css_classes(taxon)[:label].should be_html_safe
    end

  end

  describe 'taxon rank css classes' do

    it 'should return the right ones' do
      taxon = Factory :genus, :name => 'Atta'
      css_classes_for_rank(taxon).should == ['genus', 'taxon']
    end

  end
end
