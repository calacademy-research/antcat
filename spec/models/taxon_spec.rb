require 'spec_helper'

describe Taxon do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :protonym }
  it { is_expected.to allow_value(nil).for :type_name }
  it { is_expected.to allow_value(nil).for :status } # should probably not...
  it do
    is_expected.to validate_inclusion_of(:biogeographic_region)
      .in_array(BiogeographicRegion::REGIONS).allow_nil
  end
  it { is_expected.to have_many :history_items }
  it { is_expected.to have_many :reference_sections }
  it { is_expected.to belong_to :type_name }

  describe "scopes" do
    let(:subfamily) { create :subfamily }

    describe ".valid" do
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

    describe ".extant" do
      let!(:extant_genus) { create :genus, subfamily: subfamily }
      before { create :genus, subfamily: subfamily, fossil: true }

      it "only includes extant taxa" do
        expect(subfamily.genera.extant).to eq [extant_genus]
      end
    end

    describe ".self_join_on" do
      let!(:atta) { create_genus "Atta", fossil: true }
      let!(:atta_major) { create_species "Atta major", genus: atta }

      it "handles self-referential condition" do
        extant_with_fossil_parent = described_class.self_join_on(:genus)
          .where(fossil: false, taxa_self_join_alias: { fossil: true })
        expect(extant_with_fossil_parent.count).to eq 1
        expect(extant_with_fossil_parent.first).to eq atta_major

        # Make sure test case isn't playing tricks with us.
        atta.update_columns fossil: false
        expect(extant_with_fossil_parent.count).to eq 0
      end
    end

    describe ".ranks and .exclude_ranks" do
      before do
        create :subfamily
        create :genus
        create :species
        create :subspecies
      end

      def unique_ranks query
        query.uniq.pluck(:type).sort
      end

      describe ".ranks" do
        it "only returns taxa of the specified types" do
          results = unique_ranks described_class.ranks(Species, Genus)
          expect(results.sort).to eq ["Genus", "Species"]
        end

        it "handles symbols" do
          expect(unique_ranks described_class.ranks(:species, :Genus))
            .to eq ["Genus", "Species"]
        end

        it "handles strings" do
          expect(unique_ranks described_class.ranks("Species", "genus"))
            .to eq ["Genus", "Species"]
        end

        it "handles single items" do
          expect(unique_ranks described_class.ranks("Species")).to eq ["Species"]
        end
      end

      describe ".exclude_ranks" do
        it "excludes taxa of the specified types" do
          results = unique_ranks described_class.exclude_ranks(Species, Genus)
          expected = unique_ranks(described_class) - ["Species", "Genus"]
          expect(results).to eq expected
        end
      end
    end
  end

  describe ".find_by_name" do
    context 'when nothing matches' do
      it "returns nil" do
        expect(described_class.find_by_name('sdfsdf')).to eq nil
      end
    end

    context 'when there are more than one matche' do
      let!(:name) { create :genus_name, name: 'Monomorium' }
      before { 2.times { create :genus, name: name } }

      it "returns one of the items (hmm)" do
        expect(described_class.find_by_name('Monomorium').name).to eq name
      end
    end
  end

  describe "#biogeographic_region" do
    context 'when saving taxon' do
      let(:taxon) { create :species }

      it "nilifies blank strings" do
        taxon.biogeographic_region = ""
        taxon.save

        expect(taxon.biogeographic_region).to be nil
      end
    end
  end

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.name.rank).to eq 'subfamily'
    end
  end

  describe "#homonym_replaced_by, #homonym_replaced and #homonym_replaced_by?" do
    it "can be a homonym of something else" do
      taxon = build_stubbed :taxon
      another_taxon = build_stubbed :taxon, status: 'homonym', homonym_replaced_by: taxon

      expect(another_taxon).to be_homonym
      expect(another_taxon.homonym_replaced_by).to eq taxon
    end

    context "when it' not a homonym replaced by something" do
      let(:genus) { build_stubbed :genus }
      let(:another_genus) { build_stubbed :genus }

      it "should not think it is" do
        expect(genus).not_to be_homonym_replaced_by another_genus
        expect(genus.homonym_replaced).to be_nil
      end
    end

    context 'when it is a homonym replaced by something' do
      let(:replacement) { create :genus }
      let(:homonym) { create :genus, homonym_replaced_by: replacement, status: 'homonym' }

      it "should think it is" do
        expect(homonym).to be_homonym_replaced_by replacement
        expect(replacement.homonym_replaced).to eq homonym
      end
    end
  end

  describe "#protonym" do
    # Changed this because synonyms, homonyms will use the same protonym
    context "when the taxon it's attached to is destroyed, even if another taxon is using it" do
      let!(:protonym) { create :protonym }
      let!(:genus) { create_genus protonym: protonym }

      before { create_genus protonym: protonym }

      it "doesn't destroy the protonym" do
        expect { genus.destroy }.not_to change { Protonym.count }
      end
    end
  end

  describe "#history_items" do
    let(:taxon) { create :family }

    context 'when deleting a taxon' do
      let!(:history_item) { taxon.history_items.create! taxt: 'taxt' }

      it "cascades to delete history items" do
        expect { taxon.destroy }
          .to change { TaxonHistoryItem.exists? history_item.id }.from(true).to(false)
      end
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times { |number| taxon.history_items.create! taxt: "#{number}" }

      expect(taxon.history_items.map(&:taxt)).to eq ['0','1','2']
    end
  end

  describe "#reference_sections" do
    let(:taxon) { create :family }

    context 'when deleting a taxon' do
      let!(:reference_section) { taxon.reference_sections.create! references_taxt: 'foo' }

      it "cascades to delete the reference sections" do
        expect { taxon.destroy }
          .to change { ReferenceSection.exists? reference_section.id }.from(true).to(false)
      end
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times do |number|
        taxon.reference_sections.create! references_taxt: "#{number}"
      end

      expect(taxon.reference_sections.map(&:references_taxt)).to eq ['0','1','2']
    end
  end

  describe "#author_citation" do
    it "delegates to the protonym" do
      genus = build_stubbed :genus
      expect_any_instance_of(Reference)
        .to receive(:keey_without_letters_in_year).and_return 'Bolton 2005'

      expect(genus.author_citation).to eq 'Bolton 2005'
    end

    context "when a recombination in a different genus" do
      let(:species) { create_species 'Atta minor' }
      let(:protonym_name) { create_species_name 'Eciton minor' }

      it "surrounds it in parentheses" do
        expect_any_instance_of(Reference)
          .to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'

        expect(species.author_citation).to eq '(Bolton, 2005)'
      end
    end

    context "when the name simply differs" do
      let(:species) { create_species 'Atta minor maxus' }
      let(:protonym_name) { create_subspecies_name 'Atta minor minus' }

      it "doesn't surround in parentheses" do
        expect_any_instance_of(Reference)
          .to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species.author_citation).to eq 'Bolton, 2005'
      end
    end

    context "when there isn't a protonym authorship" do
      let(:species) { create_species 'Atta minor maxus' }
      let(:protonym_name) { create_subspecies_name 'Eciton minor maxus' }

      it "handles it" do
        expect(species.protonym).to receive(:authorship).and_return nil
        expect(species.author_citation).to be_nil
      end
    end
  end

  describe "#protonym" do
    context 'when taxon is deleted' do
      it "doesn't delete the protonym" do
        expect(described_class.count).to be_zero
        expect(Protonym.count).to be_zero

        genus = create :genus, tribe: nil, subfamily: nil
        expect(described_class.count).to eq 1
        expect(Protonym.count).to eq 1

        genus.destroy
        expect(described_class.count).to be_zero
        expect(Protonym.count).to eq 1
      end
    end
  end

  describe "#parent and #parent=" do
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
      context "when the taxon is a `Family`" do
        let(:family) { create :family }

        it "returns nil" do
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

    context "when new parent is same as old parent" do
      before { subspecies.update_parent old_parent }

      it "does nothing if the parent doesn't actually change" do
        expect(subspecies.species).to eq old_parent
        expect(subspecies.name.name).to eq 'Atta major medius minor'
      end
    end

    context "when new parent is not same as old parent" do
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

  # TODO move to `taxa/synonyms_spec.rb`.
  describe "#current_valid_taxon_including_synonyms" do
    context 'when there are no synonyms' do
      let!(:current_valid_taxon) { create_genus }
      let!(:taxon) { create_genus current_valid_taxon: current_valid_taxon }

      it "returns the field contents" do
        expect(taxon.current_valid_taxon_including_synonyms).to eq current_valid_taxon
      end
    end

    context 'when a senior synonym exists' do
      let!(:senior) { create_genus }
      let!(:current_valid_taxon) { create_genus }
      let!(:taxon) { create_synonym senior, current_valid_taxon: current_valid_taxon }

      it "returns the senior synonym" do
        expect(taxon.current_valid_taxon_including_synonyms).to eq senior
      end
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
    it "finds the latest senior synonym that's valid (this spec fails a lot)" do
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

    context 'when no senior synonyms are valid' do
      let!(:invalid_senior) { create_genus status: 'homonym' }
      let!(:another_invalid_senior) { create_genus status: 'homonym' }
      let!(:taxon) { create_synonym invalid_senior }

      before { Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon }

      it "returns nil" do
        expect(taxon.current_valid_taxon_including_synonyms).to be_nil
      end
    end

    context "when there's a synonym of a synonym" do
      let!(:senior_synonym_of_senior_synonym) { create_genus }
      let!(:senior_synonym) { create_genus status: 'synonym' }
      let!(:taxon) { create_genus status: 'synonym' }

      before do
        Synonym.create! junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym
        Synonym.create! junior_synonym: taxon, senior_synonym: senior_synonym
      end

      it "returns the senior synonym of the senior synonym" do
        expect(taxon.current_valid_taxon_including_synonyms).to eq senior_synonym_of_senior_synonym
      end
    end
  end
end
