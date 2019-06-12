require "spec_helper"

describe TaxonDecorator::ChildList do
  describe "#call" do
    context 'when taxon is a family' do
      let!(:family) { create :family }

      context "when children are genera incertae sedis in Formicidae" do
        let!(:taxon) { create :genus, incertae_sedis_in: 'family', subfamily: nil }

        specify do
          expect(described_class[family]).to eq(
            [
              { label: "Subfamily of Formicidae", children: [Subfamily.first] },
              { label: "Genus <i>incertae sedis</i> in Formicidae", children: [taxon] }
            ]
          )
        end
      end
    end

    context 'when taxon is a subfamily' do
      let!(:subfamily) { create :subfamily }

      context "when taxon has extant and exting tribes" do
        let!(:taxon) { create :tribe, subfamily: subfamily }
        let!(:fossil_taxon) { create :tribe, :fossil, subfamily: subfamily }

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Tribe (extant) of #{subfamily.name_cache}", children: [taxon] },
              { label: "Tribe (extinct) of #{subfamily.name_cache}", children: [fossil_taxon] }
            ]
          )
        end
      end

      context "when taxon has genera incertae sedis" do
        let!(:taxon) { create :genus, subfamily: subfamily, incertae_sedis_in: 'subfamily' }

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Genus <i>incertae sedis</i> in #{subfamily.name_cache}", children: [taxon] }
            ]
          )
        end
      end

      context "when taxon has collective group names" do
        let!(:taxon) { create :genus, subfamily: subfamily, status: Status::COLLECTIVE_GROUP_NAME }

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Collective group name in #{subfamily.name_cache}", children: [taxon] }
            ]
          )
        end
      end
    end
  end
end
