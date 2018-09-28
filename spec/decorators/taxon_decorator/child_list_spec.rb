require "spec_helper"

describe TaxonDecorator::ChildList do
  let(:subfamily) { create :subfamily }

  describe "#child_list" do
    context "formats a tribes list" do
      let!(:taxon) { create :tribe, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, subfamily.tribes, true)).
          to eq %{<div><span class="caption">Tribe (extant) of <span>#{subfamily.name_cache}</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>}
      end
    end

    context "formats a child list, specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, true)).
          to eq %{<div><span class="caption">Genus (extant) of <span>#{subfamily.name_cache}</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>}
      end
    end

    context "formats a genera list, not specifying extinctness" do
      let!(:taxon) { create :genus, subfamily: subfamily }

      specify do
        expect(described_class.new(subfamily).send(:child_list, Genus.all, false)).
          to eq %(<div><span class="caption">Genus of <span>#{subfamily.name_cache}</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>)
      end
    end

    context "formats an incertae sedis genera list" do
      let!(:taxon) { create :genus, subfamily: subfamily, incertae_sedis_in: 'subfamily' }

      specify do
        expect(described_class.new(subfamily).send(:child_list, [taxon], false, incertae_sedis_in: 'subfamily')).
          to eq %(<div><span class="caption">Genus <i>incertae sedis</i> in <span>#{subfamily.name_cache}</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>)
      end
    end

    context "when children are genera incertae sedis in Formicidae" do
      let!(:family) { create :family }
      let!(:taxon) { create :genus, subfamily: nil }

      specify do
        expect(described_class.new(family).send(:child_list, [taxon], false)).
          to eq %(<div><span class="caption">Genus <i>incertae sedis</i> in <span>Formicidae</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>)
      end
    end
  end

  describe "#collective_group_name_child_list" do
    let!(:taxon) { create :genus, subfamily: subfamily, status: Status::COLLECTIVE_GROUP_NAME }

    it "formats a list of collective group names" do
      expect(described_class.new(subfamily).send(:collective_group_name_child_list)).
        to eq %(<div><span class="caption">Collective group name in <span>#{subfamily.name_cache}</span></span>: <a href="/catalog/#{taxon.id}">#{taxon.name.name_html}</a>.</div>)
    end
  end

  describe "#child_list_query" do
    let!(:subfamily) { create :subfamily }
    let!(:atta) { create :genus, subfamily: subfamily }
    let!(:eciton) { create :genus, subfamily: subfamily, fossil: true }
    let!(:aneuretus) do
      create :genus, subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'
    end

    before { create :genus, :synonym, subfamily: subfamily }

    it "finds all genera for the taxon if there are no conditions" do
      results = described_class.new(subfamily).send :child_list_query, :genera
      expect(results).to match_array [aneuretus, atta, eciton]

      results = described_class.new(subfamily).send :child_list_query, :genera, fossil: true
      expect(results).to match_array [aneuretus, eciton]

      results = described_class.new(subfamily).send :child_list_query, :genera, incertae_sedis_in: 'subfamily'
      expect(results).to match_array [aneuretus]
    end

    it "doesn't include invalid taxa" do
      results = described_class.new(subfamily).send :child_list_query, :genera
      expect(results).to match_array [aneuretus, atta, eciton]
    end
  end
end
