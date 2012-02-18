# coding: UTF-8
require 'spec_helper'

describe Formatters::IndexFormatter do
  before do
    # test IndexFormatter via module that includes it
    @formatter = Formatters::CatalogFormatter
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
        genus = Factory :genus, name: 'Atta', type_taxon_name: 'Atta major', type_taxon_rank: 'species'
        @formatter.format_headline_type(genus, nil).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>.</span>}
      end

      it "should show the type taxon with extra Taxt" do
        genus = Factory :genus, :name => 'Atta', :type_taxon_rank => 'species', :type_taxon_taxt => ', by monotypy', type_taxon_name: 'Atta major'
        @formatter.format_headline_type(genus, nil).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>, by monotypy</span>}
      end
    end

  end

  #describe "Taxonomic history" do
    #before do
      #@taxon = Factory :family
    #end
    #describe "Taxonomic history formatting" do
      #it "should format a number of items together in order" do
        #@taxon.taxonomic_history_items.create! :taxt => 'Ant'
        #@taxon.taxonomic_history_items.create! :taxt => 'Taxonomy'
        #@formatter.format_history(@taxon, nil).should ==
          #'<h4>Taxonomic history</h4>' +
          #'<div class="history">' +
            #'<div class="history_item">Ant.</div>' +
            #'<div class="history_item">Taxonomy.</div>' +
          #'</div>'
      #end
    #end
    #describe "Taxonomic history item formatting" do
      #it "should format a phrase" do
        #@formatter.format_history_item('phrase', nil).should == '<div class="history_item">phrase.</div>'
      #end
      #it "should format a ref" do
        #reference = Factory :article_reference
        #Formatters::ReferenceFormatter.should_receive(:format_inline_citation).with(reference, nil).and_return 'foo'
        #@formatter.format_history_item("{ref #{reference.id}}", nil).should == '<div class="history_item">foo.</div>'
      #end
      #it "should not freak if the ref is malformed" do
        #@formatter.format_history_item("{ref sdf}", nil).should == '<div class="history_item">{ref sdf}.</div>'
      #end
      #it "should not freak if the ref points to a reference that doesn't exist" do
        #@formatter.format_history_item("{ref 12345}", nil).should == '<div class="history_item">{ref 12345}.</div>'
      #end
    #end
  #end

  #describe "Reference sections" do
    #before do
      #@taxon = Factory :family
    #end
    #describe "Reference sections formatting" do
      #it "should format a number of items together in order" do
        #@taxon.reference_sections.create! title: 'Global references', references: 'A global reference'
        #@taxon.reference_sections.create! title: 'References', references: 'A reference'
        #@formatter.format_references(@taxon, nil).should ==
          #'<div class="reference_sections">' +
            #'<div class="section">' +
              #'<h4 class="title">Global references</h4>' +
              #'<div class="references">A global reference</div>' +
            #'</div>' +
            #'<div class="section">' +
              #'<h4 class="title">References</h4>' +
              #'<div class="references">A reference</div>' +
            #'</div>' +
          #'</div>'
      #end
    #end
  #end

  describe "Child lists" do
    before do
      @subfamily = Factory :subfamily, name: 'Dolichoderinae'
    end
    describe "Child lists" do
      it "should format a tribes list" do
        Factory :tribe, name: 'Attini', subfamily: @subfamily
        @formatter.format_child_list(@subfamily, @subfamily.tribes, true).should == 
%{<div class="child_list"><span class="label">Tribe (extant) of <span class="subfamily taxon">Dolichoderinae</span></span>: <span class="taxon tribe">Attini</span>.</div>}
      end
      it "should format a child list, specifying extinctness" do
        Factory :genus, name: 'Atta', subfamily: @subfamily
        @formatter.format_child_list(@subfamily, Genus.all, true).should == 
%{<div class="child_list"><span class="label">Genus (extant) of <span class="subfamily taxon">Dolichoderinae</span></span>: <span class="genus taxon">Atta</span>.</div>}
      end
      it "should format a genera list, not specifying extinctness" do
        Factory :genus, name: 'Atta', subfamily: @subfamily
        @formatter.format_child_list(@subfamily, Genus.all, false).should == 
%{<div class="child_list"><span class="label">Genus of <span class="subfamily taxon">Dolichoderinae</span></span>: <span class="genus taxon">Atta</span>.</div>}
      end
      it "should format an incertae sedis genera list" do
        genus = Factory :genus, name: 'Atta', subfamily: @subfamily, incertae_sedis_in: 'subfamily'
        @formatter.format_child_list(@subfamily, [genus], false, incertae_sedis_in: 'subfamily').should == 
%{<div class="child_list"><span class="label">Genus <i>incertae sedis</i> in <span class="subfamily taxon">Dolichoderinae</span></span>: <span class="genus taxon">Atta</span>.</div>}
      end
    end
  end

  describe "Status" do
    it "should return nothing if the status is valid" do
      taxon = Factory :genus
      @formatter.format_status(taxon).should == ''
    end
    it "should show the status if there is one" do
      taxon = Factory :genus, status: 'homonym'
      @formatter.format_status(taxon).should == 'homonym'
    end
    it "should show the seniorer synonym" do
      senior_synonym = Factory :genus, name: 'Atta'
      taxon = Factory :genus, status: 'synonym', synonym_of: senior_synonym
      result = @formatter.format_status(taxon)
      result.should == 'synonym of <span class="genus taxon">Atta</span>'
      result.should be_html_safe
    end
    it "should show where it is incertae sedis" do
      taxon = Factory :genus, incertae_sedis_in: 'family'
      result = @formatter.format_status(taxon)
      result.should == '<i>incertae sedis</i> in family'
      result.should be_html_safe
    end
  end

end
