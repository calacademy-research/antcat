require 'spec_helper'

describe Taxon do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :protonym }
  it { is_expected.to validate_inclusion_of(:status).in_array(Status::STATUSES) }
  it do
    expect(subject).to validate_inclusion_of(:biogeographic_region).
      in_array(Taxon::BIOGEOGRAPHIC_REGIONS).allow_nil
  end

  describe 'relations' do
    it { is_expected.to have_many(:history_items).dependent(:destroy) }
    it { is_expected.to have_many(:reference_sections).dependent(:destroy) }
    it { is_expected.to belong_to(:protonym).dependent(false) }
  end

  describe "scopes" do
    describe ".self_join_on" do
      let!(:genus) { create :genus, fossil: true }
      let!(:species) { create :species, genus: genus }

      it "handles self-referential condition" do
        query = -> do
          described_class.self_join_on(:genus).
            where(fossil: false, taxa_self_join_alias: { fossil: true })
        end

        expect(query.call).to eq [species]
        genus.update fossil: false
        expect(query.call).to eq []
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

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.name.rank).to eq 'subfamily'
    end
  end

  describe "#author_citation" do
    context "when a recombination in a different genus" do
      let(:species) { create_species 'Atta minor' }
      let(:protonym_name) { create :species_name, name: 'Eciton minor' }

      before do
        expect_any_instance_of(Reference).
          to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'
      end

      it "surrounds it in parentheses" do
        expect(species.author_citation).to eq '(Bolton, 2005)'
      end

      specify { expect(species.author_citation).to be_html_safe }
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
end
