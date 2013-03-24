# coding: UTF-8
require 'spec_helper'

describe Formatters::TaxonFormatter do
  before do
    @formatter = Formatters::TaxonFormatter
  end

  describe "Taxon" do
    it "should work" do
      @formatter.new(create_genus, nil).format
    end
  end

  describe "Header formatting" do
    describe "Header name" do
      it "should format a subspecies with > 3 epithets" do
        formica = create_genus 'Formica'
        rufa = create_species 'rufa', genus: formica
        major_name = Name.create! name: 'Formica rufa pratensis major',
                                  epithet_html: '<i>major</i>',
                                  epithets: 'rufa pratensis major'
        major = create_subspecies name: major_name, species: rufa, genus: rufa.genus
        @formatter.new(major).header_name.should ==
          %{<a href=\"http://www.antcat.org/catalog/#{formica.id}\"><i>Formica</i></a> } +
          %{<a href=\"http://www.antcat.org/catalog/#{rufa.id}\"><i>rufa</i></a> } +
          %{<a href=\"http://www.antcat.org/catalog/#{major.id}\"><i>pratensis major</i></a>}
      end
    end
  end

  describe "Headline formatting" do

    describe "Protonym" do
      it "should format a family name in the protonym" do
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:family_or_subfamily_name, name: 'Dolichoderinae')
        @formatter.new(nil).protonym_name(protonym).should == '<b>Dolichoderinae</b>'
      end
      it "should format a genus name in the protonym" do
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:genus_name, name: 'Atari')
        @formatter.new(nil).protonym_name(protonym).should == '<b><i>Atari</i></b>'
      end
      it "should format a fossil" do
        protonym = FactoryGirl.create :protonym, name: FactoryGirl.create(:genus_name, name: 'Atari'), fossil: true
        @formatter.new(nil).protonym_name(protonym).should == '<b><i>&dagger;</i><i>Atari</i></b>'
      end
    end

    describe "Type" do
      before do
        @species_name = FactoryGirl.create :species_name, name: 'Atta major', epithet: 'major'
      end
      it "should show the type taxon" do
        genus = create_genus 'Atta', type_name: @species_name
        @formatter.new(genus).headline_type.should ==
%{<span class="type">Type-species: <span class="species taxon"><i>Atta major</i></span>.</span>}
      end
      it "should show the type taxon with extra Taxt" do
        genus = create_genus 'Atta', type_name: @species_name, type_taxt: ', by monotypy'
        @formatter.new(genus).headline_type.should ==
%{<span class="type">Type-species: <span class="species taxon"><i>Atta major</i></span>, by monotypy</span>}
      end
    end

    describe "Linking to the other site" do
      it "should link to a species" do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        species = create_species 'Atta major', genus: genus, subfamily: subfamily
        @formatter.new(species).link_to_other_site.should == %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?name=major&genus=atta&rank=species&project=worldants" target="_blank">AntWeb</a>}
      end
      it "should link to a subspecies" do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        species = create_species 'Atta major', genus: genus, subfamily: subfamily
        species = create_subspecies 'Atta major nigrans', species: species, genus: genus, subfamily: subfamily
        @formatter.new(species).link_to_other_site.should == %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?name=major nigrans&genus=atta&rank=species&project=worldants" target="_blank">AntWeb</a>}
      end
      it "should not link to an invalid taxon" do
        subfamily = create_subfamily 'Dolichoderinae', status: 'synonym'
        @formatter.new(subfamily).link_to_other_site.should be_nil
      end
    end

    describe "Linking to AntWiki" do
      it "should link to a subfamily" do
        @formatter.new(create_subfamily 'Dolichoderinae').link_to_antwiki.should ==
          %{<a class="link_to_external_site" href="http://www.antwiki.org/Dolichoderinae" target="_blank">AntWiki</a>}
      end
      it "should link to a species" do
        @formatter.new(create_species 'Atta major').link_to_antwiki.should ==
          %{<a class="link_to_external_site" href="http://www.antwiki.org/Atta_major" target="_blank">AntWiki</a>}
      end
    end
  end

  describe "Child lists" do
    before do
      @subfamily = create_subfamily 'Dolichoderinae'
    end
    describe "Child lists" do
      it "should format a tribes list" do
        attini = create_tribe 'Attini', subfamily: @subfamily
        @formatter.new(nil).child_list(@subfamily, @subfamily.tribes, true).should == 
%{<div class="child_list"><span class="label">Tribe (extant) of <span class="name subfamily taxon">Dolichoderinae</span></span>: <a href="/catalog/#{attini.id}">Attini</a>.</div>}
      end
      it "should format a child list, specifying extinctness" do
        atta = create_genus 'Atta', subfamily: @subfamily
        @formatter.new(nil).child_list(@subfamily, Genus.all, true).should == 
%{<div class="child_list"><span class="label">Genus (extant) of <span class="name subfamily taxon">Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
      end
      it "should format a genera list, not specifying extinctness" do
        atta = create_genus 'Atta', subfamily: @subfamily
        @formatter.new(nil).child_list(@subfamily, Genus.all, false).should == 
%{<div class="child_list"><span class="label">Genus of <span class="name subfamily taxon">Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
      end
      it "should format an incertae sedis genera list" do
        genus = create_genus 'Atta', subfamily: @subfamily, incertae_sedis_in: 'subfamily'
        @formatter.new(nil).child_list(@subfamily, [genus], false, incertae_sedis_in: 'subfamily').should == 
%{<div class="child_list"><span class="label">Genus <i>incertae sedis</i> in <span class="name subfamily taxon">Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
      end
      it "should format a list of collective group names" do
        genus = create_genus 'Atta', subfamily: @subfamily, status: 'collective group name'
        @formatter.new(nil).collective_group_name_child_list(@subfamily).should ==
%{<div class="child_list"><span class="label">Collective group name in <span class="name subfamily taxon">Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
      end
    end
  end

  describe "Status" do
    it "should return nothing if the status is valid" do
      taxon = create_genus
      @formatter.new(taxon).status.should == ''
    end
    it "should show the status if there is one" do
      taxon = create_genus status: 'homonym'
      @formatter.new(taxon).status.should == 'homonym'
    end
    it "should show one synonym" do
      senior_synonym = create_genus 'Atta'
      taxon = create_synonym senior_synonym
      result = @formatter.new(taxon).status
      result.should == %{synonym of <a href="/catalog/#{senior_synonym.id}"><i>Atta</i></a>}
      result.should be_html_safe
    end
    it "should show all synonyms" do
      senior_synonym = create_genus 'Atta'
      other_senior_synonym = create_genus 'Eciton'
      taxon = create_synonym senior_synonym
      Synonym.create! senior_synonym: other_senior_synonym, junior_synonym: taxon
      result = @formatter.new(taxon).status
      result.should == %{synonym of <a href="/catalog/#{senior_synonym.id}"><i>Atta</i></a>, <a href="/catalog/#{other_senior_synonym.id}"><i>Eciton</i></a>}
    end
    it "should not freak out if the senior synonym hasn't been set yet" do
      taxon = create_genus status: 'synonym'
      @formatter.new(taxon).status.should == 'synonym'
    end
    it "should show where it is incertae sedis" do
      taxon = create_genus incertae_sedis_in: 'family'
      result = @formatter.new(taxon).status
      result.should == '<i>incertae sedis</i> in family'
      result.should be_html_safe
    end
  end

  describe 'Taxon statistics' do
    it "should get the statistics, then format them" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return extant: :foo
      formatter = Formatters::TaxonFormatter.new subfamily
      Formatters::StatisticsFormatter.should_receive(:statistics).with({extant: :foo}, {})
      formatter.statistics
    end
    it "should just return nil if there are no statistics" do
      subfamily = mock
      subfamily.should_receive(:statistics).and_return nil
      formatter = Formatters::TaxonFormatter.new subfamily
      Formatters::StatisticsFormatter.should_not_receive :statistics
      formatter.statistics.should == ''
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = create_genus
      genus.should_receive(:statistics).and_return extant: {species: {'valid' => 2}}
      formatter = Formatters::TaxonFormatter.new genus
      formatter.statistics(include_invalid: false).should == "<div class=\"statistics\"><p class=\"taxon_statistics\">2 species</p></div>"
    end
    it "should not leave a comma at the end if only showing valid taxa" do
      genus = create_genus
      genus.should_receive(:statistics).and_return :extant => {:species => {'valid' => 2}}
      formatter = Formatters::TaxonFormatter.new genus
      formatter.statistics(include_invalid: false).should == "<div class=\"statistics\"><p class=\"taxon_statistics\">2 species</p></div>"
    end
  end

  describe "Taxon link class methods" do
    describe "Creating a link from another site to a taxon on AntCat" do
      it "should create the link" do
        genus = create_genus
        @formatter.link_to_antcat(genus).should ==
          %{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}" target="_blank">AntCat</a>}
      end
    end
    describe "Creating a link from AntCat to a taxon on AntCat" do
      it "should creat the link" do
        genus = create_genus 'Atta'
        @formatter.link_to_taxon(genus).should == %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
      end
    end
  end

  describe "Parentage string" do
    it "should handle the family" do
      @formatter.new(create_family).parentage_string.should == 'Family'
    end
    it "should handle a subfamily" do
      subfamily = create_subfamily
      @formatter.new(subfamily).parentage_string.should == 'Subfamily'
    end
    it "should handle a tribe" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      @formatter.new(tribe).parentage_string.should == 'Tribe'
    end
    it "should handle a genus" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, subfamily: subfamily
      @formatter.new(genus).parentage_string.should == 'Genus'
    end
    it "should handle a genus without a tribe" do
      subfamily = create_subfamily
      genus = create_genus subfamily: subfamily, tribe: nil
      @formatter.new(genus).parentage_string.should == 'Genus'
    end
    it "should handle a genus without a subfamily" do
      subfamily = create_subfamily
      genus = create_genus subfamily: nil, tribe: nil
      @formatter.new(genus).parentage_string.should == 'Genus'
    end
    it "should handle a subgenus" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, subfamily: subfamily
      subgenus = create_subgenus genus: genus
      @formatter.new(subgenus).parentage_string.should == genus.name.name
    end
    it "should handle a species" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, subfamily: subfamily
      species = create_species genus: genus
      @formatter.new(species).parentage_string.should == genus.name.name
    end
    it "should handle a subspecies" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, subfamily: subfamily
      species = create_species genus: genus
      subspecies = create_subspecies species: species, genus: genus
      @formatter.new(subspecies).parentage_string.should == species.name.name
    end
    it "should handle a subspecies without a species" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, subfamily: subfamily
      subspecies = create_subspecies species: nil, genus: genus
      @formatter.new(subspecies).parentage_string.should == "#{genus.name} (no species)"
    end
  end

end
