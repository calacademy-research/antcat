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
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:family_or_subfamily_name, name: 'Dolichoderinae')
        @formatter.format_protonym_name(protonym).should ==
          '<span class="name subfamily taxon">Dolichoderinae</span>'
      end
      it "should format a genus name in the protonym" do
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:genus_name, name: 'Atari')
        @formatter.format_protonym_name(protonym).should ==
          '<span class="genus name taxon"><i>Atari</i></span>'
      end
      it "should format a fossil" do
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:genus_name, name: 'Atari'), fossil: true
        @formatter.format_protonym_name(protonym).should ==
          '<span class="genus name taxon">&dagger;<i>Atari</i></span>'
      end
    end

    describe "Type" do
      before do
        @species_name = FactoryGirl.create :species_name, name: 'Atta major', epithet: 'major'
      end
      it "should show the type taxon" do
        genus = create_genus 'Atta', type_name: @species_name
        @formatter.format_headline_type(genus, nil).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>.</span>}
      end
      it "should show the type taxon with extra Taxt" do
        genus = create_genus 'Atta', type_name: @species_name, type_taxt: ', by monotypy'
        @formatter.format_headline_type(genus, nil).should ==
%{<span class="type">Type-species: <span class="species taxon">Atta major</span>, by monotypy</span>}
      end

    end
  end

  describe "Child lists" do
    before do
      @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
    end
    describe "Child lists" do
      it "should format a tribes list" do
        FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), subfamily: @subfamily
        @formatter.format_child_list(@subfamily, @subfamily.tribes, true).should == 
%{<div class="child_list"><span class="label">Tribe (extant) of <span class="name subfamily taxon">Dolichoderinae</span></span>: <span class="name taxon tribe">Attini</span>.</div>}
      end
      it "should format a child list, specifying extinctness" do
        create_genus 'Atta', subfamily: @subfamily
        @formatter.format_child_list(@subfamily, Genus.all, true).should == 
%{<div class="child_list"><span class="label">Genus (extant) of <span class="name subfamily taxon">Dolichoderinae</span></span>: <span class="genus name taxon"><i>Atta</i></span>.</div>}
      end
      it "should format a genera list, not specifying extinctness" do
        create_genus 'Atta', subfamily: @subfamily
        @formatter.format_child_list(@subfamily, Genus.all, false).should == 
%{<div class="child_list"><span class="label">Genus of <span class="name subfamily taxon">Dolichoderinae</span></span>: <span class="genus name taxon"><i>Atta</i></span>.</div>}
      end
      it "should format an incertae sedis genera list" do
        genus = create_genus 'Atta', subfamily: @subfamily, incertae_sedis_in: 'subfamily'
        @formatter.format_child_list(@subfamily, [genus], false, incertae_sedis_in: 'subfamily').should == 
%{<div class="child_list"><span class="label">Genus <i>incertae sedis</i> in <span class="name subfamily taxon">Dolichoderinae</span></span>: <span class="genus name taxon"><i>Atta</i></span>.</div>}
      end
    end
  end

  describe "Status" do
    it "should return nothing if the status is valid" do
      taxon = create_genus
      @formatter.format_status(taxon).should == ''
    end
    it "should show the status if there is one" do
      taxon = create_genus status: 'homonym'
      @formatter.format_status(taxon).should == 'homonym'
    end
    it "should show the seniorer synonym" do
      senior_synonym = create_genus 'Atta'
      taxon = create_genus status: 'synonym', synonym_of: senior_synonym
      result = @formatter.format_status(taxon)
      result.should == 'synonym of <span class="genus name taxon"><i>Atta</i></span>'
      result.should be_html_safe
    end
    it "should not freak out if the senior synonym hasn't been set yet" do
      taxon = create_genus status: 'synonym', synonym_of: nil
      @formatter.format_status(taxon).should == 'synonym'
    end
    it "should show where it is incertae sedis" do
      taxon = create_genus incertae_sedis_in: 'family'
      result = @formatter.format_status(taxon)
      result.should == '<i>incertae sedis</i> in family'
      result.should be_html_safe
    end
  end

end
