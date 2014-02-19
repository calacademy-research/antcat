# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Fields and validations" do
    it "should require a name" do
      FactoryGirl.build(:taxon, name: nil).should_not be_valid
      taxon = FactoryGirl.create :taxon, name: FactoryGirl.create(:name, name: 'Cerapachynae')
      taxon.name.to_s.should == 'Cerapachynae'
      taxon.should be_valid
    end
    it "should be (Rails) valid with a nil status" do
      FactoryGirl.build(:taxon).should be_valid
      FactoryGirl.build(:taxon, status: 'valid').should be_valid
    end
    it "when status 'valid', should not be invalid" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_invalid
    end
    it "should be able to be unidentifiable" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_unidentifiable
      taxon.update_attribute :status, 'unidentifiable'
      taxon.should be_unidentifiable
      taxon.should be_invalid
    end
    it "should be able to be a collective group name" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_collective_group_name
      taxon.update_attribute :status, 'collective group name'
      taxon.should be_collective_group_name
      taxon.should be_invalid
    end
    it "should be able to be an ichnotaxon" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_ichnotaxon
      taxon.update_attribute :ichnotaxon, true
      taxon.should be_ichnotaxon
      taxon.should_not be_invalid
    end
    it "should be able to be unavailable" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_unavailable
      taxon.should be_available
      taxon.update_attribute :status, 'unavailable'
      taxon.should be_unavailable
      taxon.should_not be_available
      taxon.should be_invalid
    end
    it "should be able to be excluded" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_excluded_from_formicidae
      taxon.update_attribute :status, 'excluded from Formicidae'
      taxon.should be_excluded_from_formicidae
      taxon.should be_invalid
    end
    it "should be able to be a fossil" do
      taxon = FactoryGirl.build :taxon
      taxon.should_not be_fossil
      taxon.fossil.should == false
      taxon.update_attribute :fossil, true
      taxon.should be_fossil
    end
    it "should raise if anyone calls #children directly" do
      lambda {Taxon.new.children}.should raise_error NotImplementedError
    end
    it "should be able to be a homonym of something else" do
      neivamyrmex = FactoryGirl.create :taxon
      acamatus = FactoryGirl.create :taxon, status: 'homonym', homonym_replaced_by: neivamyrmex
      acamatus.reload
      acamatus.should be_homonym
      acamatus.homonym_replaced_by.should == neivamyrmex
    end
    it "should be able to have an incertae_sedis_in" do
      myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
      myanmyrma.reload
      myanmyrma.incertae_sedis_in.should == 'family'
      myanmyrma.should_not be_invalid
    end
    it "should be able to say whether it is incertae sedis in a particular rank" do
      myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
      myanmyrma.reload
      myanmyrma.should be_incertae_sedis_in('family')
    end
  end

  describe "Rank" do
    it "should return a lowercase version" do
      FactoryGirl.create(:subfamily).name.rank.should == 'subfamily'
    end
  end

  describe "Being a homonym replaced by something" do
    it "should not think it's a homonym replaced by something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_homonym_replaced_by another_genus
      genus.homonym_replaced.should be_nil
    end
    it "should think it's a homonym replaced by something when it is" do
      replacement = FactoryGirl.create :genus
      homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym'
      homonym.should be_homonym_replaced_by replacement
      replacement.homonym_replaced.should == homonym
    end
  end

  describe "Protonym" do
    it "should have a protonym" do
      taxon = Family.new
      taxon.protonym.should be_nil
      taxon.build_protonym name: FactoryGirl.create(:name, name: 'Formicariae')
    end
    it "should destroy the protonym when the taxon it's attached to is destroyed, even if another taxon is using it, because they shouldn't" do
      protonym = FactoryGirl.create :protonym
      atta = create_genus protonym: protonym
      eciton = create_genus protonym: protonym
      protonym_count = Protonym.count
      atta.destroy
      Protonym.count.should == protonym_count -1
    end
  end

  describe "Type name" do
    it "should have a type name" do
      taxon = FactoryGirl.create :family
      taxon.type_name = FactoryGirl.create(:family_name, name: 'Formicariae')
      taxon.save!
      taxon = Taxon.find taxon
      taxon.type_name.to_s.should == 'Formicariae'
      taxon.type_name.rank.should == 'family'
    end
    it "should not be required" do
      taxon = FactoryGirl.create :family, type_name: nil
      taxon.should be_valid
    end
  end

  describe "Taxonomic history items" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.history_items.should be_empty
      taxon.history_items.create! taxt: 'foo'
      taxon.reload.history_items.map(&:taxt).should == ['foo']
    end
    it "should cascade to delete history items when it's deleted" do
      taxon = FactoryGirl.create :family
      history_item = taxon.history_items.create! taxt: 'taxt'
      TaxonHistoryItem.find_by_id(history_item.id).should_not be_nil
      taxon.destroy
      TaxonHistoryItem.find_by_id(history_item.id).should be_nil
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.history_items.create! taxt: '1'
      taxon.history_items.create! taxt: '2'
      taxon.history_items.create! taxt: '3'
      taxon.history_items.map(&:taxt).should == ['1','2','3']
      taxon.history_items.first.move_to_bottom
      taxon.history_items(true).map(&:taxt).should == ['2','3','1']
    end
  end

  describe "Reference sections" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.should be_empty
      taxon.reference_sections.create! references_taxt: 'foo'
      taxon.reload.reference_sections.map(&:references_taxt).should == ['foo']
    end
    it "should cascade to delete the reference sections when it's deleted" do
      taxon = FactoryGirl.create :family
      reference_section = taxon.reference_sections.create! references_taxt: 'foo'
      taxon.destroy
      ReferenceSection.find_by_id(reference_section.id).should be_nil
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.create! references_taxt: '1'
      taxon.reference_sections.create! references_taxt: '2'
      taxon.reference_sections.create! references_taxt: '3'
      taxon.reference_sections.map(&:references_taxt).should == ['1','2','3']
      taxon.reference_sections.first.move_to_bottom
      taxon.reference_sections(true).map(&:references_taxt).should == ['2','3','1']
    end
  end

  describe "Other attributes" do
    describe "Author last names string" do
      it "should delegate to the protonym" do
        genus = create_genus
        genus.protonym.should_receive(:author_last_names_string).and_return 'Bolton'
        genus.author_last_names_string.should == 'Bolton'
      end
      it "should handle it if there simply isn't a protonym authorship" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Eciton minor maxus'
        species.protonym.should_receive(:author_last_names_string).and_return nil
        species.author_last_names_string.should be_nil
      end
    end

    describe "Year" do
      it "should delegate to the protonym" do
        genus = create_genus
        genus.protonym.should_receive(:year).and_return '2001'
        genus.year.should == '2001'
      end
    end

    describe "Authorship string" do
      it "should delegate to the protonym" do
        genus = create_genus
        genus.protonym.should_receive(:authorship_string).and_return 'Bolton 2005'
        genus.authorship_string.should == 'Bolton 2005'
      end
      it "should surround in parentheses, if a recombination in a different genus" do
        species = create_species 'Atta minor'
        protonym_name = create_species_name 'Eciton minor'
        species.protonym.stub(:name).and_return protonym_name
        species.protonym.stub(:authorship_string).and_return 'Bolton, 2005'
        species.authorship_string.should == '(Bolton, 2005)'
      end
      it "should not surround in parentheses, if the name simply differs" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Atta minor minus'
        species.protonym.should_receive(:name).and_return protonym_name
        species.protonym.should_receive(:authorship_string).and_return 'Bolton, 2005'
        species.authorship_string.should == 'Bolton, 2005'
      end
      it "should handle it if there simply isn't a protonym authorship" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Eciton minor maxus'
        species.protonym.should_receive(:authorship_string).and_return nil
        species.authorship_string.should be_nil
      end
    end

    describe "Authorship HTML string" do
      it "should delegate to the protonym" do
        taxon = create_taxon
        taxon.protonym.should_receive(:authorship_html_string).and_return 'XYZ'
        taxon.authorship_html_string.should == %{XYZ}
      end
    end

  end

  describe "Recombination" do
    it "should not think it's a recombination if name is same as protonym" do
      species = create_species 'Atta major'
      protonym_name = create_species_name 'Atta major'
      species.protonym.should_receive(:name).and_return protonym_name
      species.should_not be_recombination
    end
    it "should think it's a recombination if genus part of name is different than genus part of protonym" do
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'
      species.protonym.should_receive(:name).and_return protonym_name
      species.should be_recombination
    end
    it "should not think it's a recombination if genus part of name is same as genus part of protonym" do
      species = create_species 'Atta minor maxus'
      protonym_name = create_subspecies_name 'Atta minor minus'
      species.protonym.should_receive(:name).and_return protonym_name
      species.should_not be_recombination
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
      @subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Atta', 'Eciton']
      @subfamily.child_list_query(:genera, fossil: true).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Eciton']
      @subfamily.child_list_query(:genera, incertae_sedis_in: 'subfamily').map(&:name).map(&:to_s).sort.should == ['Aneuretus']
    end
    it "should not include invalid taxa" do
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), subfamily: @subfamily, status: 'synonym'
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Eciton'), subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Aneuretus'), subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      @subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Eciton']
    end
  end

  describe "Cascading delete" do
    it "should delete the protonym when the taxon is deleted" do
      Taxon.count.should be_zero
      Protonym.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      Taxon.count.should == 1
      Protonym.count.should == 1

      genus.destroy
      Taxon.count.should be_zero
      Protonym.count.should == 0
    end
    it "should delete history and reference sections when the taxon is deleted" do
      Taxon.count.should be_zero
      ReferenceSection.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      genus.reference_sections.create! title_taxt: 'title', references_taxt: 'references'
      ReferenceSection.count.should == 1

      genus.destroy
      ReferenceSection.count.should be_zero
    end
  end

  describe "Setting and getting parent virtual field" do
    it "should be able to assign from an object" do
      genus = FactoryGirl.create :genus
      subfamily = FactoryGirl.create :subfamily
      genus.parent = subfamily
      genus.save!
      genus.reload.subfamily.should == subfamily
    end
    it "should be able to assign from an id" do
      genus = FactoryGirl.create :genus
      subfamily = FactoryGirl.create :subfamily
      genus.parent = subfamily.id
      genus.save!
      genus.reload.subfamily.should == subfamily
    end
    describe "Tribes, where a child can have multiple parents" do
      it "should assign to both parents when assigning to one" do
        subfamily = FactoryGirl.create :subfamily
        tribe = FactoryGirl.create :tribe, subfamily: subfamily
        protonym = FactoryGirl.create :protonym
        genus = Genus.create! name: FactoryGirl.create(:name, name: 'Aneuretus'), protonym: protonym
        genus.parent = tribe
        genus.tribe.should == tribe
        genus.subfamily.should == subfamily
      end
    end
    it "should give the parent of a family as nil" do
      family = FactoryGirl.create :family
      family.parent.should be_nil
    end
  end

  describe "Updating the parent" do
    before do
      @atta = create_genus 'Atta'
      @eciton = create_genus 'Eciton'
      @old_parent = create_species 'Atta major', genus: @atta
      @new_parent = create_species 'Eciton nigrus', genus: @eciton

      subspecies_name = create_subspecies_name 'Atta major medius minor'
      subspecies_name.update_attribute :protonym_html, '<i>Atta major medius minor</i>'
      @subspecies = create_subspecies name: subspecies_name, species: @old_parent
    end

    it "should do nothing if the parent doesn't actually change" do
      @subspecies.update_parent @old_parent
      @subspecies.species.should == @old_parent
      @subspecies.name.name.should == 'Atta major medius minor'
    end

    it "should change the species of a subspecies" do
      @subspecies.update_parent @new_parent
      @subspecies.species.should == @new_parent
    end

    it "should change the genus of a subspecies" do
      @subspecies.update_parent @new_parent
      @subspecies.species.should == @new_parent
      @subspecies.genus.should == @new_parent.genus
    end

    it "should change the subfamily of a subspecies" do
      @subspecies.update_parent @new_parent
      @subspecies.subfamily.should == @new_parent.subfamily
    end

    it "should change the name, etc., of a subspecies" do
      @subspecies.update_parent @new_parent
      name = @subspecies.name
      name.name.should == 'Eciton nigrus medius minor'
      name.name_html.should == '<i>Eciton nigrus medius minor</i>'
      name.epithet.should == 'minor'
      name.epithet_html.should == '<i>minor</i>'
      name.epithets.should == 'nigrus medius minor'
      name.protonym_html.should == '<i>Atta major medius minor</i>'
    end

    it "should change the cached name, etc., of a subspecies" do
      @subspecies.update_parent @new_parent
      @subspecies.name_cache.should == 'Eciton nigrus medius minor'
      @subspecies.name_html_cache.should == '<i>Eciton nigrus medius minor</i>'
    end

  end

  describe "Scopes" do
    describe "the 'valid' scope" do
      it "should only include valid taxa" do
        subfamily = FactoryGirl.create :subfamily
        replacement = FactoryGirl.create :genus, subfamily: subfamily
        homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym', subfamily: subfamily
        synonym = create_synonym replacement, subfamily: subfamily
        subfamily.genera.valid.should == [replacement]
      end
    end
    describe "the 'extant' scope" do
      it "should only include extant taxa" do
        subfamily = FactoryGirl.create :subfamily
        extant_genus = FactoryGirl.create :genus, subfamily: subfamily
        FactoryGirl.create :genus, subfamily: subfamily, fossil: true
        subfamily.genera.extant.should == [extant_genus]
      end
    end
    describe "ordered by name" do
      it "should order by name" do
        zymacros = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Zymacros')
        atta = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Atta')
        Taxon.ordered_by_name.should == [atta, zymacros]
      end
    end
  end

  describe "Original combination" do
    it "should be nil if there was no recombining" do
      create_genus.original_combination.should be_nil
    end
    it "is the protonym, otherwise" do
      original_combination = create_species 'Atta major'
      recombination = create_species 'Eciton major'
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!
      recombination.original_combination.should == original_combination
    end
  end

  describe "Type specimen URL" do
    it "should make sure it has a protocol" do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "Hello World!"
      taxon = FactoryGirl.create :species
      taxon.type_specimen_url = 'antcat.org/1.pdf'
      taxon.save!
      taxon.reload.type_specimen_url.should == 'http://antcat.org/1.pdf'
      taxon.save!
      taxon.reload.type_specimen_url.should == 'http://antcat.org/1.pdf'
    end
    it "should make sure it's a valid URL" do
      taxon = FactoryGirl.build :species, type_specimen_url: '*'
      taxon.should_not be_valid
      taxon.errors.full_messages.should =~ ['Type specimen url is not in a valid format']
    end
    it "should make sure it exists" do
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Hello World!'
      taxon = FactoryGirl.create :species, type_specimen_url: 'http://antwiki.org/1.pdf'
      taxon.should be_valid
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Not Found', status: 404
      taxon.should_not be_valid
      taxon.errors.full_messages.should =~ ['Type specimen url was not found']
    end
  end

  describe "Finding the current valid taxon, including synonyms" do
    it "should return the field contents if there are no synonyms" do
      current_valid_taxon = create_genus
      taxon = create_genus current_valid_taxon: current_valid_taxon
      taxon.current_valid_taxon_including_synonyms.should == current_valid_taxon
    end
    it "should return the senior synonym if it exists" do
      senior = create_genus
      current_valid_taxon = create_genus
      taxon = create_synonym senior, current_valid_taxon: current_valid_taxon
      taxon.current_valid_taxon_including_synonyms.should == senior
    end
    it "should find the latest senior synonym that's valid" do
      valid_senior = create_genus
      invalid_senior = create_genus status: 'homonym'
      taxon = create_genus status: 'synonym'
      Synonym.create! senior_synonym: valid_senior, junior_synonym: taxon
      Synonym.create! senior_synonym: invalid_senior, junior_synonym: taxon
      taxon.current_valid_taxon_including_synonyms.should == valid_senior
    end
    it "should handle when no senior synonyms are valid" do
      invalid_senior = create_genus status: 'homonym'
      another_invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon
      taxon.current_valid_taxon_including_synonyms.should be_nil
    end
    it "should handle when there's a synonym of a synonym" do
      senior_synonym_of_senior_synonym = create_genus
      senior_synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym

      taxon = create_genus status: 'synonym'
      Synonym.create! junior_synonym: taxon, senior_synonym: senior_synonym

      taxon.current_valid_taxon_including_synonyms.should == senior_synonym_of_senior_synonym
    end
    describe "Including the taxon itself" do
      it "should return the taxon itself if no senior synonyms and no current_valid_taxon" do
        taxon = create_genus
        taxon.current_valid_taxon_including_synonyms_and_self.should == taxon
      end
    end
  end

end
