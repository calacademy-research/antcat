require 'spec_helper'

describe Taxon do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :protonym }
  it { is_expected.to validate_inclusion_of(:status).in_array(Status::STATUSES) }
  it do
    expect(subject).to validate_inclusion_of(:biogeographic_region).
      in_array(Taxon::BIOGEOGRAPHIC_REGIONS).allow_nil
  end

  describe "scopes" do
    let(:subfamily) { create :subfamily }

    describe ".valid" do
      let!(:valid_taxon) { create :genus, subfamily: subfamily }

      before do
        create :genus, :homonym, homonym_replaced_by: valid_taxon, subfamily: subfamily
      end

      it "only includes valid taxa" do
        expect(subfamily.genera.valid).to eq [valid_taxon]
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
      let!(:atta) { create :genus, fossil: true }
      let!(:atta_major) { create :species, genus: atta }

      it "handles self-referential condition" do
        extant_with_fossil_parent = described_class.self_join_on(:genus).
          where(fossil: false, taxa_self_join_alias: { fossil: true })
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
        query.distinct.pluck(:type).sort
      end

      describe ".ranks" do
        it "only returns taxa of the specified types" do
          results = unique_ranks described_class.ranks(Species, Genus)
          expect(results.sort).to eq ["Genus", "Species"]
        end

        it "handles symbols" do
          expect(unique_ranks(described_class.ranks(:species, :Genus))).
            to eq ["Genus", "Species"]
        end

        it "handles strings" do
          expect(unique_ranks(described_class.ranks("Species", "genus"))).
            to eq ["Genus", "Species"]
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

    context 'when there are more than one matches' do
      let!(:name) { create :genus_name, name: 'Monomorium' }

      before { 2.times { create :genus, name: name } }

      it "returns one of the items (hmm)" do
        expect(described_class.find_by_name('Monomorium').name).to eq name
      end
    end
  end

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.name.rank).to eq 'subfamily'
    end
  end

  describe "#protonym" do
    context "when the taxon it's attached to is destroyed, even if another taxon is using it" do
      let!(:protonym) { create :protonym }
      let!(:family) { create :family, protonym: protonym }

      before { create :family, protonym: protonym }

      it "doesn't destroy the protonym" do
        expect { family.destroy }.not_to change { Protonym.count }
      end
    end
  end

  describe "#history_items" do
    let(:taxon) { create :family }

    context 'when deleting a taxon' do
      let!(:history_item) { taxon.history_items.create! taxt: 'taxt' }

      it "cascades to delete history items" do
        expect { taxon.destroy }.to change { TaxonHistoryItem.exists? history_item.id }.to(false)
      end
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times { |number| taxon.history_items.create! taxt: "#{number}" }

      expect(taxon.history_items.map(&:taxt)).to eq ['0', '1', '2']
    end
  end

  describe "#reference_sections" do
    let(:taxon) { create :family }

    context 'when deleting a taxon' do
      let!(:reference_section) { taxon.reference_sections.create! references_taxt: 'foo' }

      it "cascades to delete the reference sections" do
        expect { taxon.destroy }.
          to change { ReferenceSection.exists? reference_section.id }.from(true).to(false)
      end
    end

    it "shows the items in the order in which they were added to the taxon" do
      3.times do |number|
        taxon.reference_sections.create! references_taxt: "#{number}"
      end

      expect(taxon.reference_sections.map(&:references_taxt)).to eq ['0', '1', '2']
    end
  end

  describe "#author_citation" do
    it "delegates to the protonym" do
      genus = build_stubbed :genus
      expect_any_instance_of(Reference).
        to receive(:keey_without_letters_in_year).and_return 'Bolton 2005'

      expect(genus.author_citation).to eq 'Bolton 2005'
    end

    context "when a recombination in a different genus" do
      let(:species) { create_species 'Atta minor' }
      let(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "surrounds it in parentheses" do
        expect_any_instance_of(Reference).
          to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'

        expect(species.author_citation).to eq '(Bolton, 2005)'
      end
    end

    context "when the name simply differs" do
      let(:species) { create_species 'Atta minor maxus' }
      let(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "doesn't surround in parentheses" do
        expect_any_instance_of(Reference).
          to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species.author_citation).to eq 'Bolton, 2005'
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

  describe "#parent=" do
    let(:genus) { create :genus }
    let(:subfamily) { create :subfamily }

    it "can be assigned from an object" do
      genus.parent = subfamily
      genus.save!
      expect(genus.reload.subfamily).to eq subfamily
    end
  end

  describe "#update_parent" do
    let(:old_parent) { create_species 'Atta major', genus: create_genus('Atta') }
    let(:new_parent) { create_species 'Eciton nigrus', genus: create_genus('Eciton') }
    let(:subspecies) do
      create :subspecies, name: create(:subspecies_name, name: 'Atta major medius minor'),
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
end
