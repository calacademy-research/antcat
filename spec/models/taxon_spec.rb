require 'spec_helper'

describe Taxon do
  describe "Fields and validations" do
    it "requires a name" do
      taxon = build_stubbed :taxon
      expect(taxon).to be_valid

      taxon.name = nil
      expect(taxon).not_to be_valid
    end

    # TODO it probably should not be, but adding validation now may break many tests.
    it "is (Rails) valid with a nil status" do
      taxon = create :taxon
      taxon.status = nil
      expect(taxon).to be_valid
    end

    context "when status 'valid'" do
      it "is not invalid" do
        taxon = build_stubbed :taxon
        taxon.status = "valid"
        expect(taxon).not_to be_invalid
      end
    end

    describe "shared setup" do
      let(:taxon) { build_stubbed :taxon }

      it "can be unidentifiable" do
        expect(taxon).not_to be_unidentifiable
        taxon.status = 'unidentifiable'
        expect(taxon).to be_unidentifiable
        expect(taxon).to be_invalid
      end

      it "can be a collective group name" do
        expect(taxon).not_to be_collective_group_name
        taxon.status = 'collective group name'
        expect(taxon).to be_collective_group_name
        expect(taxon).to be_invalid
      end

      it "can be an ichnotaxon" do
        expect(taxon).not_to be_ichnotaxon
        taxon.ichnotaxon = true
        expect(taxon).to be_ichnotaxon
        expect(taxon).not_to be_invalid
      end

      it "can be unavailable" do
        expect(taxon).not_to be_unavailable
        expect(taxon).to be_available
        taxon.status = 'unavailable'
        expect(taxon).to be_unavailable
        expect(taxon).not_to be_available
        expect(taxon).to be_invalid
      end

      it "can be excluded from Formicidae" do
        expect(taxon).not_to be_excluded_from_formicidae
        taxon.status = 'excluded from Formicidae'
        expect(taxon).to be_excluded_from_formicidae
        expect(taxon).to be_invalid
      end

      it "can be a fossil" do
        expect(taxon).not_to be_fossil
        expect(taxon.fossil).to eq false
        taxon.fossil = true
        expect(taxon).to be_fossil
      end
    end

    it "can be a homonym of something else" do
      neivamyrmex = build_stubbed :taxon
      acamatus = build_stubbed :taxon, status: 'homonym', homonym_replaced_by: neivamyrmex

      expect(acamatus).to be_homonym
      expect(acamatus.homonym_replaced_by).to eq neivamyrmex
    end

    it "can have an incertae_sedis_in" do
      myanmyrma = build_stubbed :taxon, incertae_sedis_in: 'family'
      expect(myanmyrma.incertae_sedis_in).to eq 'family'
      expect(myanmyrma).not_to be_invalid
    end

    it "can say whether it is incertae sedis in a particular rank" do
      myanmyrma = build_stubbed :taxon, incertae_sedis_in: 'family'
      expect(myanmyrma).to be_incertae_sedis_in 'family'
    end

    describe "#biogeographic_region" do
      let(:taxon) { build_stubbed :species }

      it "allows only allowed regions" do
        taxon.biogeographic_region = "Australasia"
        expect(taxon.valid?).to be true

        taxon.biogeographic_region = "Ancient Egypt"
        expect(taxon.valid?).to be false
      end

      it "allows nil" do
        taxon.biogeographic_region = nil
        expect(taxon.valid?).to be true
      end

      it "nilifies blank strings on save" do
        taxon = create :species
        taxon.biogeographic_region = ""
        taxon.save

        expect(taxon.biogeographic_region).to be nil
      end
    end
  end

  #TODO remove?
  describe "Rank" do
    it "returns a lowercase version" do
      taxon = build_stubbed :subfamily
      expect(taxon.name.rank).to eq 'subfamily'
    end
  end

  describe "Being a homonym replaced by something" do
    it "should not think it's a homonym replaced by something when it's not" do
      genus = build_stubbed :genus
      another_genus = build_stubbed :genus

      expect(genus).not_to be_homonym_replaced_by another_genus
      expect(genus.homonym_replaced).to be_nil
    end

    it "should think it's a homonym replaced by something when it is" do
      replacement = create :genus
      homonym = create :genus, homonym_replaced_by: replacement, status: 'homonym'
      expect(homonym).to be_homonym_replaced_by replacement
      expect(replacement.homonym_replaced).to eq homonym
    end
  end

  describe "#protonym" do
    it "can have a protonym" do
      taxon = Family.new
      expect(taxon.protonym).to be_nil
      taxon.build_protonym name: create(:name, name: 'Formicariae')
      expect(taxon.protonym).to_not be_nil
    end

    # Changed this because synonyms, homonyms will use the same protonym
    context "when the taxon it's attached to is destroyed, even if another taxon is using it" do
      it "doesn't destroy the protonym" do
        protonym = create :protonym
        atta = create_genus protonym: protonym
        eciton = create_genus protonym: protonym

        expect { atta.destroy }.not_to change { Protonym.count }
      end
    end
  end

  describe "#type_name" do
    it "can have a type name" do
      taxon = create :family
      taxon.type_name = create :family_name, name: 'Formicariae'
      taxon.save!
      taxon = Taxon.find taxon.id

      expect(taxon.type_name.to_s).to eq 'Formicariae'
      expect(taxon.type_name.rank).to eq 'family'
    end

    it "is not required" do
      taxon = create :family, type_name: nil
      expect(taxon).to be_valid
    end
  end

  describe "#history_items" do
    let(:taxon) { create :family }

    it "can have some" do
      expect(taxon.history_items).to be_empty
      taxon.history_items.create! taxt: 'foo'
      expect(taxon.reload.history_items.map(&:taxt)).to eq ['foo']
    end

    it "cascades to delete history items when it's deleted" do
      history_item = taxon.history_items.create! taxt: 'taxt'
      expect(TaxonHistoryItem.find_by(id: history_item.id)).not_to be_nil
      taxon.destroy
      expect(TaxonHistoryItem.find_by(id: history_item.id)).to be_nil
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times { |number| taxon.history_items.create! taxt: "#{number}" }

      expect(taxon.history_items.map(&:taxt)).to eq ['0','1','2']
      taxon.history_items.first.move_to_bottom
      expect(taxon.history_items(true).map(&:taxt)).to eq ['1','2','0']
    end
  end

  describe "#reference_sections" do
    let(:taxon) { create :family }

    it "can have some" do
      expect(taxon.reference_sections).to be_empty
      taxon.reference_sections.create! references_taxt: 'foo'
      expect(taxon.reload.reference_sections.map(&:references_taxt)).to eq ['foo']
    end

    it "cascades to delete the reference sections when it's deleted" do
      reference_section = taxon.reference_sections.create! references_taxt: 'foo'
      taxon.destroy
      expect(ReferenceSection.find_by(id: reference_section.id)).to be_nil
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times do |number|
        taxon.reference_sections.create! references_taxt: "#{number}"
      end

      expect(taxon.reference_sections.map(&:references_taxt)).to eq ['0','1','2']
      taxon.reference_sections.first.move_to_bottom
      expect(taxon.reference_sections(true).map(&:references_taxt)).to eq ['1','2','0']
    end
  end

  describe "Other attributes" do
    describe "#author_last_names_string" do
      it "delegates to the protonym" do
        genus = build_stubbed :genus
        expect(genus.protonym).to receive(:author_last_names_string).and_return 'Bolton'
        expect(genus.author_last_names_string).to eq 'Bolton'
      end

      context "when there isn't a protonym authorship" do
        it "handles it" do
          species = build_stubbed :species

          expect(species.protonym).to receive(:author_last_names_string).and_return nil
          expect(species.author_last_names_string).to be_nil
        end
      end
    end

    describe "#year" do
      it "delegates to the protonym" do
        genus = build_stubbed :genus
        expect(genus.protonym).to receive(:year).and_return '2001'
        expect(genus.year).to eq '2001'
      end
    end

    describe "#authorship_string" do
      it "delegates to the protonym" do
        genus = build_stubbed :genus
        expect(genus.protonym).to receive(:authorship_string).and_return 'Bolton 2005'
        expect(genus.authorship_string).to eq 'Bolton 2005'
      end

      context "when a recombination in a different genus" do
        it "surrounds it in parentheses" do
          species = create_species 'Atta minor'
          protonym_name = create_species_name 'Eciton minor'
          allow(species.protonym).to receive(:name).and_return protonym_name
          allow(species.protonym).to receive(:authorship_string).and_return 'Bolton, 2005'

          expect(species.authorship_string).to eq '(Bolton, 2005)'
        end
      end

      it "doesn't surround in parentheses, if the name simply differs" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Atta minor minus'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species.protonym).to receive(:authorship_string).and_return 'Bolton, 2005'
        expect(species.authorship_string).to eq 'Bolton, 2005'
      end

      context "when there isn't a protonym authorship" do
        it "handles it" do
          species = create_species 'Atta minor maxus'
          protonym_name = create_subspecies_name 'Eciton minor maxus'

          expect(species.protonym).to receive(:authorship_string).and_return nil
          expect(species.authorship_string).to be_nil
        end
      end
    end
  end

  describe "#recombination?" do
    context "name is same as protonym" do
      it "it is not a recombination" do
        species = create_species 'Atta major'
        protonym_name = create_species_name 'Atta major'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end

    context "genus part of name is different than genus part of protonym" do
      it "it is a recombination" do
        species = create_species 'Atta minor'
        protonym_name = create_species_name 'Eciton minor'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).to be_recombination
      end
    end

    context "genus part of name is same as genus part of protonym" do
      it "it is not a recombination" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Atta minor minus'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end
  end

  describe "Cascading delete" do
    it "doesn't delete the protonym when the taxon is deleted" do
      expect(Taxon.count).to be_zero
      expect(Protonym.count).to be_zero

      genus = create :genus, tribe: nil, subfamily: nil
      expect(Taxon.count).to eq 1
      expect(Protonym.count).to eq 1

      genus.destroy
      expect(Taxon.count).to be_zero
      expect(Protonym.count).to eq 1
    end

    it "deletes history and reference sections when the taxon is deleted" do
      expect(Taxon.count).to be_zero
      expect(ReferenceSection.count).to be_zero

      genus = create :genus, tribe: nil, subfamily: nil
      genus.reference_sections.create! title_taxt: 'title', references_taxt: 'references'
      expect(ReferenceSection.count).to eq 1

      genus.destroy
      expect(ReferenceSection.count).to be_zero
    end
  end

  describe "Setting and getting parent virtual field" do
    let(:genus) { create :genus }
    let(:subfamily) { create :subfamily }

    describe "#parent=" do
      it "can be assigned from an object" do
        genus.parent = subfamily
        genus.save!
        expect(genus.reload.subfamily).to eq subfamily
      end
    end

    describe "#parent" do
      context "when the taxon is a Family" do
        it "returns nil" do
          family = create :family
          expect(family.parent).to be_nil
        end
      end
    end
  end

  describe "#update_parent" do
    let(:old_parent) { create_species 'Atta major', genus: create_genus('Atta') }
    let(:new_parent) { create_species 'Eciton nigrus', genus: create_genus('Eciton') }
    let(:subspecies) do
      create_subspecies name: create_subspecies_name('Atta major medius minor'),
        species: old_parent
    end

    it "test factories" do
      expect(subspecies.species).to eq old_parent
    end

    context "new parent is same as old aprent" do
      it "does nothing if the parent doesn't actually change" do
        subspecies.update_parent old_parent
        expect(subspecies.species).to eq old_parent
        expect(subspecies.name.name).to eq 'Atta major medius minor'
      end
    end

    context "new parent is not same as old aprent" do
      before { subspecies.update_parent new_parent }

      it "changes the species of a subspecies" do
        expect(subspecies.species).to eq new_parent
      end

      it "changes the genus of a subspecies" do
        expect(subspecies.species).to eq new_parent
        expect(subspecies.genus).to eq new_parent.genus
      end

      it "changes the subfamily of a subspecies" do
        expect(subspecies.subfamily).to eq new_parent.subfamily
      end

      it "changes the name, etc., of a subspecies" do
        name = subspecies.name
        expect(name.name).to eq 'Eciton nigrus medius minor'
        expect(name.name_html).to eq '<i>Eciton nigrus medius minor</i>'
        expect(name.epithet).to eq 'minor'
        expect(name.epithet_html).to eq '<i>minor</i>'
        expect(name.epithets).to eq 'nigrus medius minor'
      end

      it "changes the cached name, etc., of a subspecies" do
        expect(subspecies.name_cache).to eq 'Eciton nigrus medius minor'
        expect(subspecies.name_html_cache).to eq '<i>Eciton nigrus medius minor</i>'
      end
    end
  end

  describe "scopes" do
    let(:subfamily) { create :subfamily }

    describe "scope.valid" do
      it "only includes valid taxa" do
        replacement = create :genus, subfamily: subfamily
        homonym = create :genus,
          homonym_replaced_by: replacement,
          status: 'homonym',
          subfamily: subfamily
        create_synonym replacement, subfamily: subfamily

        expect(subfamily.genera.valid).to eq [replacement]
      end
    end

    describe "scope.extant" do
      it "only includes extant taxa" do
        extant_genus = create :genus, subfamily: subfamily
        create :genus, subfamily: subfamily, fossil: true

        expect(subfamily.genera.extant).to eq [extant_genus]
      end
    end

    describe "scope.order_by_name_cache" do
      let!(:zymacros) { create :subfamily, name: create(:name, name: 'Zymacros') }
      let!(:atta) { create :subfamily, name: create(:name, name: 'Atta') }

      it "orders by name" do
        expect(Taxon.order_by_name_cache).to eq [atta, zymacros]
      end
    end
  end

  describe "#original_combination" do
    it "is nil if there was no recombining" do
      genus = build_stubbed :genus
      expect(genus.original_combination).to be_nil
    end

    it "is the protonym, otherwise" do
      original_combination = create_species 'Atta major'
      recombination = create_species 'Eciton major'
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!

      expect(recombination.original_combination).to eq original_combination
    end
  end

  describe "#type_specimen_url" do
    it "makes sure it has a protocol" do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "Hello World!"
      taxon = create :species
      taxon.type_specimen_url = 'antcat.org/1.pdf'
      taxon.save!
      expect(taxon.reload.type_specimen_url).to eq 'http://antcat.org/1.pdf'
      taxon.save!
      expect(taxon.reload.type_specimen_url).to eq 'http://antcat.org/1.pdf'
    end

    it "validates the URL" do
      taxon = create :species
      taxon.type_specimen_url = '*'
      expect(taxon).not_to be_valid

      expected_error = 'Type specimen url is not in a valid format'
      expect(taxon.errors.full_messages).to match_array [expected_error]
    end

    it "validates that the URL exists" do
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Hello World!'
      taxon = create :species, type_specimen_url: 'http://antwiki.org/1.pdf'
      expect(taxon).to be_valid
      stub_request(:any, 'http://antwiki.org/1.pdf').to_return body: 'Not Found', status: 404
      expect(taxon).not_to be_valid
      expect(taxon.errors.full_messages).to match_array ['Type specimen url was not found']
    end
  end

  describe "#current_valid_taxon_including_synonyms" do
    it "returns the field contents if there are no synonyms" do
      current_valid_taxon = create_genus
      taxon = create_genus current_valid_taxon: current_valid_taxon
      expect(taxon.current_valid_taxon_including_synonyms).to eq current_valid_taxon
    end

    it "returns the senior synonym if it exists" do
      senior = create_genus
      current_valid_taxon = create_genus
      taxon = create_synonym senior, current_valid_taxon: current_valid_taxon
      expect(taxon.current_valid_taxon_including_synonyms).to eq senior
    end

    # Fails a lot. This test case is the arch enemy of AntCat's RSpec testing team.
    #
    # Changing `order(created_at: :desc)` to `order(id: :desc)` in
    # `#find_most_recent_valid_senior_synonym` *should* return the synonyms
    # in the same/intended order without risk of shuffling objects created
    # the same second. However, that makes the test fail 100%, which brings
    # me to believe that the test doesn't randomly fail -- it randomly passes.
    #
    # Use this for debugging:
    # `for i in {1..3}; do rspec ./spec/models/taxon_spec.rb:549 ; done`
    #
    # TODO semi-disabled by Russian roulette, sorry!!!!
    # Bad test practices, but this case has broken too many builds.
    it "finds the latest senior synonym that's valid" do
      if Random.rand(1..6) == 6
        valid_senior = create_genus status: 'valid'
        invalid_senior = create_genus status: 'homonym'
        taxon = create_genus status: 'synonym'
        Synonym.create! senior_synonym: valid_senior, junior_synonym: taxon
        Synonym.create! senior_synonym: invalid_senior, junior_synonym: taxon
        expect(taxon.current_valid_taxon_including_synonyms).to eq valid_senior
      else
        "Survived. Phew. Life is precious."
      end

      # If you came here because you're sad because the build broke, don't be.
      # Here's some trivia from Wikipedia to cheer you up:
      # * Due to gravity, in a properly maintained weapon with a single round
      #   inside the cylinder, the full chamber, which weighs more than the empty
      #   chambers, will usually end up near the bottom of the cylinder when its
      #   axis is not vertical, altering the odds in favor of the player.
      #
      # * In the Autobiography of Malcolm X, Malcolm X recalls an incident during
      #   his burglary career when he once played Russian roulette, pulling the
      #   trigger three times in a row to convince his partners in crime that he
      #   was not afraid to die. In the epilogue to the book, Alex Haley states
      #   that Malcolm X revealed to him that he palmed the round.
      #
      # * In 1976, Finnish magician Aimo Leikas killed himself in front of a
      #   crowd while performing his Russian roulette act. He had been performing
      #   the act for about a year, selecting six bullets from a box of assorted
      #   live and dummy ammunition.
    end

    it "handles when no senior synonyms are valid" do
      invalid_senior = create_genus status: 'homonym'
      another_invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon
      expect(taxon.current_valid_taxon_including_synonyms).to be_nil
    end

    it "handles when there's a synonym of a synonym" do
      senior_synonym_of_senior_synonym = create_genus
      senior_synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym

      taxon = create_genus status: 'synonym'
      Synonym.create! junior_synonym: taxon, senior_synonym: senior_synonym

      expect(taxon.current_valid_taxon_including_synonyms).to eq senior_synonym_of_senior_synonym
    end
  end
end
