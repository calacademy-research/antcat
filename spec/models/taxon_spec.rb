# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Fields and validations" do
    it "should require a name" do
      taxon = FactoryGirl.build(:taxon, name: nil)
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_valid
      taxon = FactoryGirl.create :taxon, name: FactoryGirl.create(:name, name: 'Cerapachynae')
      expect(taxon.name.to_s).to eq('Cerapachynae')
      expect(taxon).to be_valid
    end
    it "should be (Rails) valid with a nil status" do
      taxon = FactoryGirl.build(:taxon)
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).to be_valid
      taxon = FactoryGirl.build(:taxon, status: 'valid')
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).to be_valid
    end
    it "when status 'valid', should not be invalid" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id

      expect(taxon).not_to be_invalid
    end
    it "should be able to be unidentifiable" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_unidentifiable
      taxon.update_attribute :status, 'unidentifiable'
      expect(taxon).to be_unidentifiable
      expect(taxon).to be_invalid
    end
    it "should be able to be a collective group name" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_collective_group_name
      taxon.update_attribute :status, 'collective group name'
      expect(taxon).to be_collective_group_name
      expect(taxon).to be_invalid
    end
    it "should be able to be an ichnotaxon" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_ichnotaxon
      taxon.update_attribute :ichnotaxon, true
      expect(taxon).to be_ichnotaxon
      expect(taxon).not_to be_invalid
    end
    it "should be able to be unavailable" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_unavailable
      expect(taxon).to be_available
      taxon.update_attribute :status, 'unavailable'
      expect(taxon).to be_unavailable
      expect(taxon).not_to be_available
      expect(taxon).to be_invalid
    end
    it "should be able to be excluded" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_excluded_from_formicidae
      taxon.update_attribute :status, 'excluded from Formicidae'
      expect(taxon).to be_excluded_from_formicidae
      expect(taxon).to be_invalid
    end
    it "should be able to be a fossil" do
      taxon = FactoryGirl.build :taxon
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_fossil
      expect(taxon.fossil).to eq(false)
      taxon.update_attribute :fossil, true
      expect(taxon).to be_fossil
    end

    it "should be able to be a homonym of something else" do
      neivamyrmex = FactoryGirl.create :taxon
      FactoryGirl.create :taxon_state, taxon_id: neivamyrmex.id

      acamatus = FactoryGirl.create :taxon, status: 'homonym', homonym_replaced_by: neivamyrmex
      acamatus.reload
      expect(acamatus).to be_homonym
      expect(acamatus.homonym_replaced_by).to eq(neivamyrmex)
    end
    it "should be able to have an incertae_sedis_in" do
      myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
      myanmyrma.reload
      expect(myanmyrma.incertae_sedis_in).to eq('family')
      expect(myanmyrma).not_to be_invalid
    end
    it "should be able to say whether it is incertae sedis in a particular rank" do
      myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
      myanmyrma.reload
      expect(myanmyrma).to be_incertae_sedis_in('family')
    end
  end

  describe "Rank" do
    it "should return a lowercase version" do
      expect(FactoryGirl.create(:subfamily).name.rank).to eq('subfamily')
    end
  end

  describe "Being a homonym replaced by something" do
    it "should not think it's a homonym replaced by something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      expect(genus).not_to be_homonym_replaced_by another_genus
      expect(genus.homonym_replaced).to be_nil
    end
    it "should think it's a homonym replaced by something when it is" do
      replacement = FactoryGirl.create :genus
      homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym'
      expect(homonym).to be_homonym_replaced_by replacement
      expect(replacement.homonym_replaced).to eq(homonym)
    end
  end

  describe "Protonym" do
    it "should have a protonym" do
      taxon = Family.new
      expect(taxon.protonym).to be_nil
      taxon.build_protonym name: FactoryGirl.create(:name, name: 'Formicariae')
    end
    # Changed this because synonyms, homonyms will use the same protonym
    it "should not destroy the protonym when the taxon it's attached to is destroyed, even if another taxon is using it" do
      protonym = FactoryGirl.create :protonym
      atta = create_genus protonym: protonym
      eciton = create_genus protonym: protonym
      protonym_count = Protonym.count
      atta.destroy
      expect(Protonym.count).to eq(protonym_count)
    end
  end

  describe "Type name" do
    it "should have a type name" do
      taxon = FactoryGirl.create :family
      taxon.type_name = FactoryGirl.create(:family_name, name: 'Formicariae')
      taxon.save!
      taxon = Taxon.find taxon.id
      expect(taxon.type_name.to_s).to eq('Formicariae')
      expect(taxon.type_name.rank).to eq('family')
    end
    it "should not be required" do
      taxon = FactoryGirl.create :family, type_name: nil
      expect(taxon).to be_valid
    end
  end

  describe "Taxonomic history items" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      expect(taxon.history_items).to be_empty
      taxon.history_items.create! taxt: 'foo'
      expect(taxon.reload.history_items.map(&:taxt)).to eq(['foo'])
    end
    it "should cascade to delete history items when it's deleted" do
      taxon = FactoryGirl.create :family
      history_item = taxon.history_items.create! taxt: 'taxt'
      expect(TaxonHistoryItem.find_by_id(history_item.id)).not_to be_nil
      taxon.destroy
      expect(TaxonHistoryItem.find_by_id(history_item.id)).to be_nil
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.history_items.create! taxt: '1'
      taxon.history_items.create! taxt: '2'
      taxon.history_items.create! taxt: '3'
      expect(taxon.history_items.map(&:taxt)).to eq(['1','2','3'])
      taxon.history_items.first.move_to_bottom
      expect(taxon.history_items(true).map(&:taxt)).to eq(['2','3','1'])
    end
  end

  describe "Reference sections" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      expect(taxon.reference_sections).to be_empty
      taxon.reference_sections.create! references_taxt: 'foo'
      expect(taxon.reload.reference_sections.map(&:references_taxt)).to eq(['foo'])
    end
    it "should cascade to delete the reference sections when it's deleted" do
      taxon = FactoryGirl.create :family
      reference_section = taxon.reference_sections.create! references_taxt: 'foo'
      taxon.destroy
      expect(ReferenceSection.find_by_id(reference_section.id)).to be_nil
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.create! references_taxt: '1'
      taxon.reference_sections.create! references_taxt: '2'
      taxon.reference_sections.create! references_taxt: '3'
      expect(taxon.reference_sections.map(&:references_taxt)).to eq(['1','2','3'])
      taxon.reference_sections.first.move_to_bottom
      expect(taxon.reference_sections(true).map(&:references_taxt)).to eq(['2','3','1'])
    end
  end

  describe "Other attributes" do
    describe "Author last names string" do
      it "should delegate to the protonym" do
        genus = create_genus
        expect(genus.protonym).to receive(:author_last_names_string).and_return 'Bolton'
        expect(genus.author_last_names_string).to eq('Bolton')
      end
      it "should handle it if there simply isn't a protonym authorship" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Eciton minor maxus'
        expect(species.protonym).to receive(:author_last_names_string).and_return nil
        expect(species.author_last_names_string).to be_nil
      end
    end

    describe "Year" do
      it "should delegate to the protonym" do
        genus = create_genus
        expect(genus.protonym).to receive(:year).and_return '2001'
        expect(genus.year).to eq('2001')
      end
    end

    describe "Authorship string" do
      it "should delegate to the protonym" do
        genus = create_genus
        expect(genus.protonym).to receive(:authorship_string).and_return 'Bolton 2005'
        expect(genus.authorship_string).to eq('Bolton 2005')
      end
      it "should surround in parentheses, if a recombination in a different genus" do
        species = create_species 'Atta minor'
        protonym_name = create_species_name 'Eciton minor'
        allow(species.protonym).to receive(:name).and_return protonym_name
        allow(species.protonym).to receive(:authorship_string).and_return 'Bolton, 2005'
        expect(species.authorship_string).to eq('(Bolton, 2005)')
      end
      it "should not surround in parentheses, if the name simply differs" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Atta minor minus'
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species.protonym).to receive(:authorship_string).and_return 'Bolton, 2005'
        expect(species.authorship_string).to eq('Bolton, 2005')
      end
      it "should handle it if there simply isn't a protonym authorship" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Eciton minor maxus'
        expect(species.protonym).to receive(:authorship_string).and_return nil
        expect(species.authorship_string).to be_nil
      end
    end

    describe "Authorship HTML string" do
      it "should delegate to the protonym" do
        taxon = create_taxon
        expect(taxon.protonym).to receive(:authorship_html_string).and_return 'XYZ'
        expect(taxon.authorship_html_string).to eq(%{XYZ})
      end
    end

  end

  describe "Recombination" do
    it "should not think it's a recombination if name is same as protonym" do
      species = create_species 'Atta major'
      protonym_name = create_species_name 'Atta major'
      expect(species.protonym).to receive(:name).and_return protonym_name
      expect(species).not_to be_recombination
    end
    it "should think it's a recombination if genus part of name is different than genus part of protonym" do
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'
      expect(species.protonym).to receive(:name).and_return protonym_name
      expect(species).to be_recombination
    end
    it "should not think it's a recombination if genus part of name is same as genus part of protonym" do
      species = create_species 'Atta minor maxus'
      protonym_name = create_subspecies_name 'Atta minor minus'
      expect(species.protonym).to receive(:name).and_return protonym_name
      expect(species).not_to be_recombination
    end
  end

  describe "Child list queries" do
    before do
      @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
    end
    it "should find all genera for the taxon if there are no conditions" do
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), subfamily: @subfamily
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Eciton'), subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Aneuretus'), subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      expect(@subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort).to eq(['Aneuretus', 'Atta', 'Eciton'])
      expect(@subfamily.child_list_query(:genera, fossil: true).map(&:name).map(&:to_s).sort).to eq(['Aneuretus', 'Eciton'])
      expect(@subfamily.child_list_query(:genera, incertae_sedis_in: 'subfamily').map(&:name).map(&:to_s).sort).to eq(['Aneuretus'])
    end
    it "should not include invalid taxa" do
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), subfamily: @subfamily, status: 'synonym'
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Eciton'), subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Aneuretus'), subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      expect(@subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort).to eq(['Aneuretus', 'Eciton'])
    end
  end

  describe "Cascading delete" do
    it "should not delete the protonym when the taxon is deleted" do
      expect(Taxon.count).to be_zero
      expect(Protonym.count).to be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      expect(Taxon.count).to eq(1)
      expect(Protonym.count).to eq(1)

      genus.destroy
      expect(Taxon.count).to be_zero
      expect(Protonym.count).to eq(1)
    end
    it "should delete history and reference sections when the taxon is deleted" do
      expect(Taxon.count).to be_zero
      expect(ReferenceSection.count).to be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      genus.reference_sections.create! title_taxt: 'title', references_taxt: 'references'
      expect(ReferenceSection.count).to eq(1)

      genus.destroy
      expect(ReferenceSection.count).to be_zero
    end
  end

  describe "Setting and getting parent virtual field" do
    it "should be able to assign from an object" do
      genus = FactoryGirl.create :genus
      subfamily = FactoryGirl.create :subfamily
      genus.parent = subfamily
      genus.save!
      expect(genus.reload.subfamily).to eq(subfamily)
    end
    it "should be able to assign from an id" do
      genus = FactoryGirl.create :genus
      subfamily = FactoryGirl.create :subfamily
      genus.parent = subfamily.id
      genus.save!
      expect(genus.reload.subfamily).to eq(subfamily)
    end
    it "should give the parent of a family as nil" do
      family = FactoryGirl.create :family
      expect(family.parent).to be_nil
    end
  end

  describe "Updating the parent" do
    before do
      @atta = create_genus 'Atta'
      @eciton = create_genus 'Eciton'
      @old_parent = create_species 'Atta major', genus: @atta
      @new_parent = create_species 'Eciton nigrus', genus: @eciton

      subspecies_name = create_subspecies_name 'Atta major medius minor'
     # subspecies_name.update_attribute :protonym_html, '<i>Atta major medius minor</i>'
      @subspecies = create_subspecies name: subspecies_name, species: @old_parent
    end

    it "should do nothing if the parent doesn't actually change" do
      @subspecies.update_parent @old_parent
      expect(@subspecies.species).to eq(@old_parent)
      expect(@subspecies.name.name).to eq('Atta major medius minor')
    end

    it "should change the species of a subspecies" do
      @subspecies.update_parent @new_parent
      expect(@subspecies.species).to eq(@new_parent)
    end

    it "should change the genus of a subspecies" do
      @subspecies.update_parent @new_parent
      expect(@subspecies.species).to eq(@new_parent)
      expect(@subspecies.genus).to eq(@new_parent.genus)
    end

    it "should change the subfamily of a subspecies" do
      @subspecies.update_parent @new_parent
      expect(@subspecies.subfamily).to eq(@new_parent.subfamily)
    end

    it "should change the name, etc., of a subspecies" do
      @subspecies.update_parent @new_parent
      name = @subspecies.name
      expect(name.name).to eq('Eciton nigrus medius minor')
      expect(name.name_html).to eq('<i>Eciton nigrus medius minor</i>')
      expect(name.epithet).to eq('minor')
      expect(name.epithet_html).to eq('<i>minor</i>')
      expect(name.epithets).to eq('nigrus medius minor')
    end

    it "should change the cached name, etc., of a subspecies" do
      @subspecies.update_parent @new_parent
      expect(@subspecies.name_cache).to eq('Eciton nigrus medius minor')
      expect(@subspecies.name_html_cache).to eq('<i>Eciton nigrus medius minor</i>')
    end

  end

  describe "Scopes" do
    describe "the 'valid' scope" do
      it "should only include valid taxa" do
        subfamily = FactoryGirl.create :subfamily
        replacement = FactoryGirl.create :genus, subfamily: subfamily
        homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym', subfamily: subfamily
        synonym = create_synonym replacement, subfamily: subfamily
        expect(subfamily.genera.valid).to eq([replacement])
      end
    end
    describe "the 'extant' scope" do
      it "should only include extant taxa" do
        subfamily = FactoryGirl.create :subfamily
        extant_genus = FactoryGirl.create :genus, subfamily: subfamily
        FactoryGirl.create :genus, subfamily: subfamily, fossil: true
        expect(subfamily.genera.extant).to eq([extant_genus])
      end
    end
    describe "ordered by name" do
      it "should order by name" do
        zymacros = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Zymacros')
        atta = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Atta')
        expect(Taxon.ordered_by_name).to eq([atta, zymacros])
      end
    end
  end

  describe "Original combination" do
    it "should be nil if there was no recombining" do
      expect(create_genus.original_combination).to be_nil
    end
    it "is the protonym, otherwise" do
      original_combination = create_species 'Atta major'
      recombination = create_species 'Eciton major'
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!
      expect(recombination.original_combination).to eq(original_combination)
    end
  end

  describe "Type specimen URL" do
    it "should make sure it has a protocol" do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "Hello World!"
      taxon = FactoryGirl.create :species
      taxon.type_specimen_url = 'antcat.org/1.pdf'
      taxon.save!
      expect(taxon.reload.type_specimen_url).to eq('http://antcat.org/1.pdf')
      taxon.save!
      expect(taxon.reload.type_specimen_url).to eq('http://antcat.org/1.pdf')
    end
    it "should make sure it's a valid URL" do
      taxon = FactoryGirl.build :species, type_specimen_url: '*'
      FactoryGirl.create :taxon_state, taxon_id: taxon.id
      expect(taxon).not_to be_valid
      expect(taxon.errors.full_messages).to match_array(['Type specimen url is not in a valid format'])
    end
    it "should make sure it exists" do
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Hello World!'
      taxon = FactoryGirl.create :species, type_specimen_url: 'http://antwiki.org/1.pdf'
      expect(taxon).to be_valid
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Not Found', status: 404
      expect(taxon).not_to be_valid
      expect(taxon.errors.full_messages).to match_array(['Type specimen url was not found'])
    end
  end

  describe "Finding the current valid taxon, including synonyms" do
    it "should return the field contents if there are no synonyms" do
      current_valid_taxon = create_genus
      taxon = create_genus current_valid_taxon: current_valid_taxon
      expect(taxon.current_valid_taxon_including_synonyms).to eq(current_valid_taxon)
    end
    it "should return the senior synonym if it exists" do
      senior = create_genus
      current_valid_taxon = create_genus
      taxon = create_synonym senior, current_valid_taxon: current_valid_taxon
      expect(taxon.current_valid_taxon_including_synonyms).to eq(senior)
    end
    # Intermittent failure

    it "should find the latest senior synonym that's valid" do
      valid_senior = create_genus status: 'valid'
      invalid_senior = create_genus status: 'homonym'
      taxon = create_genus status: 'synonym'
      Synonym.create! senior_synonym: valid_senior, junior_synonym: taxon
      Synonym.create! senior_synonym: invalid_senior, junior_synonym: taxon
      expect(taxon.current_valid_taxon_including_synonyms).to eq(valid_senior)
    end
    it "should handle when no senior synonyms are valid" do
      invalid_senior = create_genus status: 'homonym'
      another_invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon
      expect(taxon.current_valid_taxon_including_synonyms).to be_nil
    end
    it "should handle when there's a synonym of a synonym" do
      senior_synonym_of_senior_synonym = create_genus
      senior_synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym

      taxon = create_genus status: 'synonym'
      Synonym.create! junior_synonym: taxon, senior_synonym: senior_synonym

      expect(taxon.current_valid_taxon_including_synonyms).to eq(senior_synonym_of_senior_synonym)
    end
    describe "Including the taxon itself" do
      it "should return the taxon itself if no senior synonyms and no current_valid_taxon" do
        taxon = create_genus
        expect(taxon.current_valid_taxon_including_synonyms_and_self).to eq(taxon)
      end
    end
  end

end
