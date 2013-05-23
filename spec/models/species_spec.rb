# coding: UTF-8
require 'spec_helper'

describe Species do
  before do
    @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
  end

  it "should have subspecies, which are its children" do
    species = create_species 'Atta chilensis'
    create_subspecies 'Atta chilensis robusta', species: species
    create_subspecies 'Atta chilensis saltensis', species: species
    species = Species.find_by_name 'Atta chilensis'
    species.subspecies.map(&:name).map(&:epithet).should =~ ['robusta', 'saltensis']
    species.children.should == species.subspecies
  end

  describe "Statistics" do
    it "should handle 0 children" do
      create_species.statistics.should == {}
    end
    it "should handle 1 valid subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      species.statistics.should == {extant: {subspecies: {'valid' => 1}}}
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      species.statistics.should == {
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      }
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      species.statistics.should == {
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      }
    end
    it "should handle 1 valid subspecies and 2 synonyms" do
      species = create_species
      create_subspecies species: species
      2.times {create_subspecies species: species, status: 'synonym'}
      species.statistics.should == {extant: {subspecies: {'valid' => 1, 'synonym' => 2}}}
    end

  end

  describe "Becoming subspecies" do
    before do
      @genus = create_genus 'Atta'
    end
    it "should turn the record into a Subspecies" do
      taxon = create_species 'Atta minor', genus: @genus
      new_species = create_species 'Atta major', genus: @genus

      taxon.become_subspecies_of new_species

      taxon = Subspecies.find taxon.id
      taxon.name.name.should == 'Atta major minor'
      taxon.name.epithets.should == 'major minor'
      taxon.should be_kind_of Subspecies
      taxon.name.should be_kind_of SubspeciesName
    end

    it "should handle when the new subspecies exists" do
      taxon = create_species 'Camponotus dallatorrei', genus: @genus
      new_species = create_species 'Camponotus alii', genus: @genus
      exisiting_subspecies = create_species 'Atta alii dallatorrei', genus: @genus
      -> {taxon.become_subspecies_of new_species}.should_raise Taxon::TaxonExists
    end

    it "should handle when the new subspecies exists, but just as the protonym of the new subspecies" do
      taxon = create_species 'Atta minor', genus: @genus
      taxon.protonym.name.name = 'Atta alii dallatorrei'
      new_species = create_species 'Atta major', genus: @genus

      taxon.become_subspecies_of new_species

      taxon = Subspecies.find taxon.id
      taxon.name.name.should == 'Atta major minor'
    end

  end

  describe "Siblings" do
    it "should return itself and its genus's species" do
      create_species
      genus = create_genus
      species = create_species genus: genus
      another_species = create_species genus: genus
      species.siblings.should =~ [species, another_species]
    end
  end

  describe "Importing" do
    it "should import a species" do
      subfamily = create_subfamily
      genus = create_genus 'Fiona', subfamily: subfamily

      species = Species.import(
        genus: genus,
        species_epithet: 'major',
        fossil: true,
        protonym: {
          genus_name: "Atta", species_epithet: 'major',
          authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        history: ['Atta major as species', 'Atta major as subspecies']
      )
      species = Species.find species
      species.name.to_s.should == 'Fiona major'
      species.should_not be_invalid
      species.should be_fossil
      species.genus.should == genus
      species.subfamily.should == subfamily
      species.history_items.map(&:taxt).should == ['Atta major as species', 'Atta major as subspecies']

      protonym = species.protonym
      protonym.name.to_s.should == 'Atta major'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == @reference
    end

    describe "Importing species that look like subspecies" do
      it "should import a species with a subspecies protonym and a list of subspecies" do
        genus = create_genus 'Aenictus'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'alluaudi',
          protonym: {
            authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}],
            genus_name:           'Aenictus',
            species_epithet:      'bottegoi',
            subspecies: [{type:   'var.',
              subspecies_epithet: 'alluaudi',
            }]
          },
          raw_history: [{subspecies: [{species_group_epithet: 'falcifer'}]}],
        )
        taxon.should be_kind_of Species
      end

      it "should import a species with a subspecies protonym that was raised to species" do
        genus = create_genus 'Anonychomyrma'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'malandana',
          protonym: {
            authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}],
            genus_name:           'Iridomyrmex',
            species_epithet:      'innocens',
            subspecies: [{type:   'r.',
              subspecies_epithet: 'malandanus',
            }]
          },
          raw_history: [{raised_to_species: {references:[]}}]
        )
        taxon.should be_kind_of Species
      end

      it "should import a species with a subspecies protonym that has 'raised to species' in the text" do
        genus = create_genus 'Anonychomyrma'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'malandana',
          protonym: {
            authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
            genus_name:           'Iridomyrmex',
            species_epithet:      'innocens',
            subspecies: [{type:   'r.',
              subspecies_epithet: 'malandanus',
            }]
          },
          raw_history: [{text: [], matched_text:'Raised to species and senior synonym of', delimiter:' '}]
        )
        taxon.should be_kind_of Species
      end

      it "should import a subspecies that was revived from synonymy as a species" do
        genus = create_genus 'Crematogaster'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'tricolor',
          protonym: {
            authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
            genus_name:           'Crematogaster',
            species_epithet:      'tricolor',
          },
          raw_history: [{revived_from_synonymy: {references:[], subspecies_of: {species_epithet: 'castanea'}}}]
        )
        Subspecies.find_by_name('Crematogaster castanea tricolor').should_not be_nil
      end
    end

  end

  describe "Updating" do
    it "should handle going through twice without changing the data!" do
      atta = create_genus 'Atta'
      data =
      {:type=>:species_record,
       genus: atta,
      :species_group_epithet=>"major",
      :protonym=>
        {:genus_name=>"Atta",
        :species_epithet=>"major",
        :authorship=>
          [{:author_names=>["Latreille"],
            :year=>"1809",
            :pages=>"152",
            :notes=>
            [[{:phrase=>"w", :delimiter=>"."},
              {:phrase=>", not m", :delimiter=>". "},
              {:phrase=>"as stated"}]],
            :matched_text=>"Santschi, 1925c: 152 (w., not m. as stated)"}],
        :locality=>"Tanzania"},
      :history=>
        [{:text=>
          [{:opening_bracket=>"["},
            {:genus_name=>"Atta",
            :species_epithet=>"major",
            :authorship=>
              [{:author_names=>["Latreille"],
                :year=>"1809",
                :pages=>"116",
                :matched_text=>""}],
            :delimiter=>". "},
            {:genus_name=>"Nomen", :species_epithet=>"nudum"},
            {:phrase=>", attributed to Stitz", :delimiter=>"."},
            {:closing_bracket=>"]"}],
          :matched_text=>
          ""}]}
      taxon = Species.import data
      taxon.protonym.authorship.notes_taxt.should == ' (w., not m. as stated)'
      taxon = Species.import data
      taxon.protonym.authorship.notes_taxt.should == ' (w., not m. as stated)'
    end
    it "should not change the history when going through twice" do
      atta = create_genus 'Atta'
      data = {
        :type=>:species_record,
        genus: atta,
        :species_group_epithet=>"major",
        :protonym=>
          {:genus_name=>"Atta",
          :species_epithet=>"major",
          :authorship=>
            [{:author_names=>["Latreille"],
              :year=>"1809",
              :pages=>"152",
              :notes=>
              [[{:phrase=>"w", :delimiter=>"."},
                {:phrase=>", not m", :delimiter=>". "},
                {:phrase=>"as stated"}]],
              :matched_text=>"Santschi, 1925c: 152 (w., not m. as stated)"}],
          :locality=>"Tanzania"},
        :history=> ['A history item']
      }
      taxon = Species.import data
      taxon.history_items.count.should == 1
      taxon = Species.import data
      taxon.history_items.count.should == 1
    end

    it "should not change the protonym name when going through twice" do
      pheidologeton = create_genus 'Pheidologeton'
      data = {
        :type=>:species_record,
        genus: pheidologeton,
        :species_group_epithet=>"fictus",
        :protonym=>
          {:genus_name=>"Pheidologeton",
          :species_epithet=>"diversus",
          :subspecies=>[{:subspecies_epithet=>"ficta", :type=>"var."}],
          :authorship=>
            [{:author_names=>["Forel"],
              :year=>"1911d",
              :pages=>"386",
              :forms=>"w.",
              :matched_text=>"Forel, 1911d: 386 (w.)"}],
          :locality=>"Vietnam"},
          history: [], raw_history: [],
      }
      taxon = Species.import data
      protonym_name = taxon.protonym.name.name
      taxon = Species.import data
      taxon.protonym.name.name.should == protonym_name
    end

    it "should not create duplicate synonyms" do
      atta = create_genus 'Atta'
      xerox = create_species 'Atta xerox', genus: atta
      data = {
        genus: xerox.genus,
        :type=>:species_record,
        :species_group_epithet=>"butteli",
        :protonym=>
          {:genus_name=>"Iridomyrmex",
          :species_epithet=>"cordatus",
          :subspecies=>
            [{:subspecies_epithet=>"protensus", :type=>"r."},
            {:subspecies_epithet=>"butteli", :type=>"var."}],
          :authorship=>
            [{:author_names=>["Forel"],
              :year=>"1913k",
              :pages=>"90",
              :forms=>"w.q.",
              :matched_text=>"Forel, 1913k: 90 (w.q.)"}],
          :locality=>"Indonesia (Sumatra)"},
        :history=>[],
        raw_history: [{synonym_ofs: [{species_epithet: 'xerox'}]}]
      }
      taxon = Species.import data
      ForwardRef.fixup
      taxon.should be_synonym_of xerox
      Synonym.count.should == 1

      taxon = Species.import data
      Synonym.count.should == 1
    end

    it "should not change the protonym name when going through twice" do
      pheidologeton = create_genus 'Pheidologeton'
      data = {
        :type=>:species_record,
        genus: pheidologeton,
        :species_group_epithet=>"fictus",
        :protonym=>
          {:genus_name=>"Pheidologeton",
          :species_epithet=>"diversus",
          :subspecies=>[{:subspecies_epithet=>"ficta", :type=>"var."}],
          :authorship=>
            [{:author_names=>["Forel"],
              :year=>"1911d",
              :pages=>"386",
              :forms=>"w.",
              :matched_text=>"Forel, 1911d: 386 (w.)"}],
          :locality=>"Vietnam"},
          history: [], raw_history: [],
      }
      taxon = Species.import data
      protonym_name = taxon.protonym.name.name
      taxon = Species.import data
      taxon.protonym.name.name.should == protonym_name
    end

    it "should update value fields" do
      tribe = create_tribe
      genus = create_genus 'Crematogaster', tribe: tribe
      data = {
        genus:                  genus,
        fossil:                 false,
        status:                 'valid',
        incertae_sedis_in:      nil,
        species_group_epithet:  'major',
        protonym: {
          genus_name:           'Crematogaster',
          species_epithet:      'major',
          authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]
        },
        history: [], raw_history: [],
      }
      taxon = Species.import data

      data[:fossil] = true
      homonym_species = create_species 'Eciton major'
      data[:homonym_replaced_by] = homonym_species
      FactoryGirl.create :article_reference, bolton_key_cache: 'Fisher 2005'
      data[:protonym][:authorship].first[:pages] = '23'

      taxon = Species.import data

      Update.count.should == 4

      update = Update.find_by_field_name 'fossil'
      update.before.should == '0'
      update.after.should == '1'
      taxon.fossil.should be_true

      update = Update.find_by_field_name 'homonym_replaced_by_id'
      update.before.should be_nil
      update.after.should == 'Eciton major'
      taxon.homonym_replaced_by.should == homonym_species

      update = Update.find_by_field_name 'pages'
      update.before.should == '124'
      update.after.should == '23'
      taxon.protonym.authorship.pages.should == '23'
    end

    it "should record creations" do
      tribe = create_tribe
      genus = create_genus 'Atta', tribe: tribe
      data = {
        genus:                  genus,
        species_group_epithet:  'minor',
        protonym: {
          genus_name:           'Atta',
          species_epithet:      'minor',
          authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]
        }, history: [], raw_history: [],
      }
      Species.import data
      taxon = Species.import data

      Update.count.should == 1
      update = Update.find_by_record_id taxon.id
      update.name.should == 'Atta minor'
      update.class_name.should == 'Species'
      update.field_name.should == 'create'
    end

    it "should create an Update only if status changes" do
      genus = create_genus 'Atta'
      data = {
        genus:                  genus,
        species_group_epithet:  'dyak',
        protonym: {
          genus_name:           'Atta',
          species_epithet:      'dyak',
          authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]
        }, history: [], raw_history: [],
      }
      species = Species.import data
      species.should be_valid
      Update.count.should == 1
      Update.first.field_name.should == 'create'

      data[:raw_history] = [{synonym_ofs: [
        {species_epithet: 'ferox'},
        {species_epithet: 'xerox'},
      ]}]
      Species.import data
      species.reload.should be_synonym
      Update.count.should == 2
      update = Update.find_by_field_name 'status'
      update.before.should == 'valid'
      update.after.should == 'synonym'
    end
  end

  describe "A manual import" do
    it "should import Myrmicium heerii" do
      genus = create_genus 'Myrmicium', status: 'excluded'
      Species.import_myrmicium_heerii
      species = Species.find_by_name 'Myrmicium heerii'
      species.status.should == 'excluded'
      species.genus.name.to_s.should == 'Myrmicium'
    end
  end

end
