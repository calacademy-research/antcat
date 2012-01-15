# coding: UTF-8
require 'spec_helper'

describe Catalog::IndexFormatter do
  before do
    @formatter = CatalogFormatter
  end

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
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>.</span>}
      end
      it "should show the type taxon with extra Taxt" do
        species = Factory :species, :name => 'major'
        genus = Factory :genus, :name => 'Atta', :type_taxon => species, :type_taxon_taxt => ', by monotypy'
        species.update_attribute :genus, genus
        @formatter.format_headline_type(genus).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>, by monotypy.</span>}
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
