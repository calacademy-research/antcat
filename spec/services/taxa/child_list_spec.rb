# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ChildList do
  describe "#call" do
    context 'when taxon is a family' do
      let!(:taxon) { create :family }

      context "when family has subfamilies and/or genera incertae sedis in Formicidae" do
        let!(:genus) { create :genus, :incertae_sedis_in_family }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "Subfamilies of #{taxon.name_cache}", children: [Subfamily.first] },
              { label: "Genera <i>incertae sedis</i> in #{taxon.name_cache}", children: [genus] }
            ]
          )
        end
      end
    end

    context 'when taxon is a subfamily' do
      let!(:taxon) { create :subfamily }

      context "when subfamily has tribes" do
        let!(:tribe) { create :tribe, subfamily: taxon }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "Tribes of #{taxon.name_cache}", children: [tribe] }
            ]
          )
        end
      end

      context "when subfamily has genera incertae sedis" do
        let!(:genus) { create :genus, :incertae_sedis_in_subfamily, subfamily: taxon }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "Genera <i>incertae sedis</i> in #{taxon.name_cache}", children: [genus] }
            ]
          )
        end
      end

      context "when subfamily has collective group names" do
        let!(:collective_group_name) do
          fossil_protonym = create :protonym, :genus_group, :fossil
          create :genus, :collective_group_name, subfamily: taxon, protonym: fossil_protonym
        end

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "Collective group names in #{taxon.name_cache}", children: [collective_group_name] }
            ]
          )
        end
      end
    end
  end
end
