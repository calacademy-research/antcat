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
    expect(species.subspecies.map(&:name).map(&:epithet)).to match_array(['robusta', 'saltensis'])
    expect(species.children).to eq(species.subspecies)
  end

  describe "Statistics" do
    it "should handle 0 children" do
      expect(create_species.statistics).to eq({})
    end
    it "should handle 1 valid subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      expect(species.statistics).to eq({extant: {subspecies: {'valid' => 1}}})
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      expect(species.statistics).to eq({
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      })
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      expect(species.statistics).to eq({
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      })
    end
    it "should handle 1 valid subspecies and 2 synonyms" do
      species = create_species
      create_subspecies species: species
      2.times {create_subspecies species: species, status: 'synonym'}
      expect(species.statistics).to eq({extant: {subspecies: {'valid' => 1, 'synonym' => 2}}})
    end

  end

  describe "Becoming subspecies" do
    before do
      @genus = create_genus 'Atta'
    end
    it "should turn the record into a Subspecies" do
      taxon = create_species 'Atta minor', genus: @genus
      taxon.protonym.name.protonym_html = 'Atta (Myrma) minor'
      taxon.protonym.name.save!
      new_species = create_species 'Atta major', genus: @genus

      taxon.become_subspecies_of new_species

      taxon = Subspecies.find taxon.id
      expect(taxon.name.name).to eq('Atta major minor')
      expect(taxon.name.epithets).to eq('major minor')
      expect(taxon.name.protonym_html).to be_nil
      expect(taxon).to be_kind_of Subspecies
      expect(taxon.name).to be_kind_of SubspeciesName
      expect(taxon.name_cache).to eq('Atta major minor')
    end

    it "should set the species, genus and subfamily" do
      taxon = create_species 'Atta minor', genus: @genus
      new_species = create_species 'Atta major', genus: @genus
      taxon.become_subspecies_of new_species
      taxon = Subspecies.find taxon.id
      expect(taxon.species).to eq(new_species)
      expect(taxon.genus).to eq(new_species.genus)
      expect(taxon.subfamily).to eq(new_species.subfamily)
    end

    it "should handle when the new subspecies exists" do
      taxon = create_species 'Camponotus dallatorrei', genus: @genus
      new_species = create_species 'Camponotus alii', genus: @genus
      existing_subspecies = create_subspecies 'Atta alii dallatorrei', genus: @genus
      expect {taxon.become_subspecies_of new_species}.to raise_error Taxon::TaxonExists
    end

    it "should handle when the new subspecies name exists, but just as the protonym of the new subspecies" do
      subspecies_name = FactoryGirl.create :subspecies_name, name: 'Atta major minor', protonym_html: '<i>Atta major minor</i>'
      taxon = create_species 'Atta minor', genus: @genus, protonym: FactoryGirl.create(:protonym, name: subspecies_name)
      new_species = create_species 'Atta major', genus: @genus

      taxon.become_subspecies_of new_species

      taxon = Subspecies.find taxon.id
      expect(taxon.name.name).to eq('Atta major minor')
      expect(taxon.protonym.name.protonym_html).to eq('<i>Atta major minor</i>')
    end

  end

  describe "Siblings" do
    it "should return itself and its genus's species" do
      create_species
      genus = create_genus
      species = create_species genus: genus
      another_species = create_species genus: genus
      expect(species.siblings).to match_array([species, another_species])
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
      expect(species.name.to_s).to eq('Fiona major')
      expect(species).not_to be_invalid
      expect(species).to be_fossil
      expect(species.genus).to eq(genus)
      expect(species.subfamily).to eq(subfamily)
      expect(species.history_items.map(&:taxt)).to eq(['Atta major as species', 'Atta major as subspecies'])

      protonym = species.protonym
      expect(protonym.name.to_s).to eq('Atta major')

      authorship = protonym.authorship
      expect(authorship.pages).to eq('124')

      expect(authorship.reference).to eq(@reference)
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
        expect(taxon).to be_kind_of Species
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
        expect(taxon).to be_kind_of Species
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
        expect(taxon).to be_kind_of Species
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
        expect(Subspecies.find_by_name('Crematogaster castanea tricolor')).not_to be_nil
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
      expect(taxon.protonym.authorship.notes_taxt).to eq(' (w., not m. as stated)')
      taxon = Species.import data
      expect(taxon.protonym.authorship.notes_taxt).to eq(' (w., not m. as stated)')
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
      expect(taxon.history_items.count).to eq(1)
      taxon = Species.import data
      expect(taxon.history_items.count).to eq(1)
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
      expect(taxon.protonym.name.name).to eq(protonym_name)
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
      expect(taxon).to be_synonym_of xerox
      expect(Synonym.count).to eq(1)

      taxon = Species.import data
      expect(Synonym.count).to eq(1)
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
      expect(taxon.protonym.name.name).to eq(protonym_name)
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
      current_valid_taxon_species = create_species 'Etta major'
      data[:homonym_replaced_by] = homonym_species
      data[:current_valid_taxon] = current_valid_taxon_species
      FactoryGirl.create :article_reference, bolton_key_cache: 'Fisher 2005'
      data[:protonym][:authorship].first[:pages] = '23'

      taxon = Species.import data

      expect(Update.count).to eq(4)

      update = Update.find_by_field_name 'fossil'
      expect(update.before).to eq('0')
      expect(update.after).to eq('1')
      expect(taxon.fossil).to be_truthy

      update = Update.find_by_field_name 'homonym_replaced_by_id'
      expect(update.before).to be_nil
      expect(update.after).to eq('Eciton major')
      expect(taxon.homonym_replaced_by).to eq(homonym_species)

      update = Update.find_by_field_name 'pages'
      expect(update.before).to eq('124')
      expect(update.after).to eq('23')
      expect(taxon.protonym.authorship.pages).to eq('23')
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

      expect(Update.count).to eq(1)
      update = Update.find_by_record_id taxon.id
      expect(update.name).to eq('Atta minor')
      expect(update.class_name).to eq('Species')
      expect(update.field_name).to eq('create')
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
      expect(species).to be_valid
      expect(Update.count).to eq(1)
      expect(Update.first.field_name).to eq('create')

      data[:raw_history] = [{synonym_ofs: [
        {species_epithet: 'ferox'},
        {species_epithet: 'xerox'},
      ]}]
      Species.import data
      expect(species.reload).to be_synonym
      expect(Update.count).to eq(2)
      update = Update.find_by_field_name 'status'
      expect(update.before).to eq('valid')
      expect(update.after).to eq('synonym')
    end
  end

  describe "A manual import" do
    it "should import Myrmicium heerii" do
      genus = create_genus 'Myrmicium', status: 'excluded from Formicidae'
      Species.import_myrmicium_heerii
      species = Species.find_by_name 'Myrmicium heerii'
      expect(species.status).to eq('excluded from Formicidae')
      expect(species.genus.name.to_s).to eq('Myrmicium')
    end
  end

end
