# coding: UTF-8
require 'spec_helper'

describe Catalog::IndexFormatter do
  before do
    @formatter = CatalogFormatter
  end

  describe "Headline formatting" do

    describe "Protonym" do
      it "should format a family name in the protonym" do
        protonym = Factory :protonym, name: 'Formcidae', rank: 'family_or_subfamily'
        @formatter.format_protonym_name(protonym).should ==
          '<span class="name subfamily taxon">Formcidae</span>'
      end
      it "should format a genus name in the protonym" do
        protonym = Factory :protonym, name: 'Atari', rank: 'genus'
        @formatter.format_protonym_name(protonym).should ==
          '<span class="genus name taxon">Atari</span>'
      end
      it "should format a fossil" do
        protonym = Factory :protonym, name: 'Atari', rank: 'genus', fossil: true
        @formatter.format_protonym_name(protonym).should ==
          '<span class="genus name taxon">&dagger;Atari</span>'
      end
    end

    describe "Type" do
      it "should show the type taxon" do
        species = Factory :species, name: 'major'
        genus = Factory :genus, name: 'Atta', type_taxon: species, type_taxon_name: 'Atta major'
        species.update_attribute :genus, genus
        @formatter.format_headline_type(genus).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span></span>}
      end

      it "should show the type taxon with extra Taxt" do
        species = Factory :species, :name => 'major'
        genus = Factory :genus, :name => 'Atta', :type_taxon => species, :type_taxon_taxt => ', by monotypy', type_taxon_name: 'Atta major'
        species.update_attribute :genus, genus
        @formatter.format_headline_type(genus).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>, by monotypy</span>}
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
        @formatter.format_history(@taxon, nil).should ==
          '<h4>Taxonomic history</h4>' +
          '<div class="history">' +
            '<div class="history_item">Ant.</div>' +
            '<div class="history_item">Taxonomy.</div>' +
          '</div>'
      end
    end
    describe "Taxonomic history item formatting" do
      it "should format a phrase" do
        @formatter.format_history_item('phrase', nil).should == '<div class="history_item">phrase.</div>'
      end
      it "should format a ref" do
        reference = Factory :article_reference
        ReferenceFormatter.should_receive(:format_inline_citation).with(reference, nil).and_return 'foo'
        @formatter.format_history_item("{ref #{reference.id}}", nil).should == '<div class="history_item">foo.</div>'
      end
      it "should not freak if the ref is malformed" do
        @formatter.format_history_item("{ref sdf}", nil).should == '<div class="history_item">{ref sdf}.</div>'
      end
      it "should not freak if the ref points to a reference that doesn't exist" do
        @formatter.format_history_item("{ref 12345}", nil).should == '<div class="history_item">{ref 12345}.</div>'
      end
    end
  end

end
