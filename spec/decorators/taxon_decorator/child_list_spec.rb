require "spec_helper"

describe TaxonDecorator::ChildList do
  include TestLinksHelpers

  let(:subfamily) { create :subfamily }

  describe "#child_list" do
    context "formats a tribes list" do
      let!(:taxon) { create :tribe, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, subfamily.tribes, true)).
          to eq %{<div><span class="caption">Tribe (extant) of <span>#{subfamily.name_cache}</span></span>: #{taxon_link(taxon)}.</div>}
      end
    end

    context "formats a child list, specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, true)).
          to eq %{<div><span class="caption">Genus (extant) of <span>#{subfamily.name_cache}</span></span>: #{taxon_link(taxon)}.</div>}
      end
    end

    context "formats a genera list, not specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, false)).
          to eq %(<div><span class="caption">Genus of <span>#{subfamily.name_cache}</span></span>: #{taxon_link(taxon)}.</div>)
      end
    end

    context "formats an incertae sedis genera list" do
      let!(:taxon) { create :genus, subfamily: subfamily, incertae_sedis_in: 'subfamily' }

      specify do
        expect(described_class.new(subfamily).send(:child_list, [taxon], false, incertae_sedis_in: 'subfamily')).
          to eq %(<div><span class="caption">Genus <i>incertae sedis</i> in <span>#{subfamily.name_cache}</span></span>: #{taxon_link(taxon)}.</div>)
      end
    end

    context "when children are genera incertae sedis in Formicidae" do
      let!(:family) { create :family }
      let!(:taxon) { create :genus, subfamily: nil }

      specify do
        expect(described_class.new(family).send(:child_list, [taxon], false)).
          to eq %(<div><span class="caption">Genus <i>incertae sedis</i> in <span>Formicidae</span></span>: #{taxon_link(taxon)}.</div>)
      end
    end
  end

  describe "#collective_group_name_child_list" do
    let!(:taxon) { create :genus, subfamily: subfamily, status: Status::COLLECTIVE_GROUP_NAME }

    it "formats a list of collective group names" do
      expect(described_class.new(subfamily).send(:collective_group_name_child_list)).
        to eq %(<div><span class="caption">Collective group name in <span>#{subfamily.name_cache}</span></span>: #{taxon_link(taxon)}.</div>)
    end
  end

  # TODO: Do not test private method. Also not very nice specs.
  describe "#child_list_query" do
    let!(:subfamily) { create :subfamily }
    let!(:atta) { create :genus, subfamily: subfamily }
    let!(:eciton) { create :genus, subfamily: subfamily, fossil: true }
    let!(:aneuretus) do
      create :genus, subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'
    end

    before { create :genus, :synonym, subfamily: subfamily }

    specify do
      results = described_class.new(subfamily).send :child_list_query, :genera
      expect(results[false]).to match_array [atta]
      expect(results[true]).to match_array [aneuretus, eciton]

      results = described_class.new(subfamily).send :child_list_query, :genera, fossil: true
      expect(results[false]).to match_array [atta]
      expect(results[true]).to match_array [aneuretus, eciton]

      results = described_class.new(subfamily).send :child_list_query, :genera, incertae_sedis_in: 'subfamily'
      expect(results[false]).to eq nil
      expect(results[true]).to match_array [aneuretus]
    end
  end
end
