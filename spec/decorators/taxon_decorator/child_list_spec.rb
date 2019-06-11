require "spec_helper"

describe TaxonDecorator::ChildList do
  include TestLinksHelpers

  let(:subfamily) { create :subfamily }

  describe "#child_list" do
    context "formats a tribes list" do
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

    context "formats a child list, specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, true)).to eq(
          label: "Genus (extant) of #{subfamily.name_cache}", children: [taxon]
        )
      end
    end

    context "formats a genera list, not specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, false)).to eq(
          label: "Genus of #{subfamily.name_cache}", children: [taxon]
        )
      end
    end

    context "formats an incertae sedis genera list" do
      let!(:taxon) { create :genus, subfamily: subfamily, incertae_sedis_in: 'subfamily' }

      specify do
        expect(described_class.new(subfamily).send(:child_list, [taxon], false, incertae_sedis_in: 'subfamily')).to eq(
          label: "Genus <i>incertae sedis</i> in #{subfamily.name_cache}", children: [taxon]
        )
      end
    end

    context "when children are genera incertae sedis in Formicidae" do
      let!(:family) { create :family }
      let!(:taxon) { create :genus, subfamily: nil }

      specify do
        expect(described_class.new(family).send(:child_list, [taxon], false)).to eq(
          label: "Genus <i>incertae sedis</i> in Formicidae", children: [taxon]
        )
      end
    end
  end

  describe "#collective_group_name_child_list" do
    let!(:taxon) { create :genus, subfamily: subfamily, status: Status::COLLECTIVE_GROUP_NAME }

    it "formats a list of collective group names" do
      expect(described_class.new(subfamily).send(:collective_group_name_child_list)).to eq(
        [
          { label: "Collective group name in #{subfamily.name_cache}", children: [taxon] }
        ]
      )
    end
  end
end
