# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ChildList do
  describe "#call" do
    context 'when taxon is a family' do
      let!(:family) { create :family }

      context "when children are genera incertae sedis in Formicidae" do
        let!(:taxon) { create :genus, :incertae_sedis_in_family }

        specify do
          expect(described_class[family]).to eq(
            [
              { label: "Subfamilies of #{family.name_cache}", children: [Subfamily.first] },
              { label: "Genera <i>incertae sedis</i> in #{family.name_cache}", children: [taxon] }
            ]
          )
        end
      end
    end

    context 'when taxon is a subfamily' do
      let!(:subfamily) { create :subfamily }

      context "when taxon has tribes" do
        let!(:taxon) { create :tribe, subfamily: subfamily }
        let!(:fossil_taxon) do
          fossil_protonym = create :protonym, :family_group, :fossil
          create :tribe, subfamily: subfamily, protonym: fossil_protonym
        end

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Tribes of #{subfamily.name_cache}", children: [taxon, fossil_taxon] }
            ]
          )
        end
      end

      context "when taxon has genera incertae sedis" do
        let!(:taxon) { create :genus, :incertae_sedis_in_subfamily, subfamily: subfamily }

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Genera <i>incertae sedis</i> in #{subfamily.name_cache}", children: [taxon] }
            ]
          )
        end
      end

      context "when taxon has collective group names" do
        let!(:taxon) do
          fossil_protonym = create :protonym, :genus_group, :fossil
          create :genus, :collective_group_name, subfamily: subfamily, protonym: fossil_protonym
        end

        specify do
          expect(described_class[subfamily]).to eq(
            [
              { label: "Collective group names in #{subfamily.name_cache}", children: [taxon] }
            ]
          )
        end
      end
    end
  end
end
