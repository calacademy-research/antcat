require "spec_helper"

describe TaxonDecorator::ChildList do
  let(:decorator_helper) { described_class }
  let(:subfamily) { create_subfamily 'Dolichoderinae' }

  describe "#child_list" do
    it "formats a tribes list" do
      attini = create_tribe 'Attini', subfamily: subfamily
      expect(decorator_helper.new(subfamily).send(:child_list, subfamily.tribes, true))
        .to eq %{<div><span class="caption">Tribe (extant) of <span>Dolichoderinae</span></span>: <a href="/catalog/#{attini.id}">Attini</a>.</div>}
    end

    it "formats a child list, specifying extinctness" do
      atta = create_genus 'Atta', subfamily: subfamily
      expect(decorator_helper.new(subfamily).send(:child_list, Genus.all, true))
        .to eq %{<div><span class="caption">Genus (extant) of <span>Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
    end

    it "formats a genera list, not specifying extinctness" do
      atta = create_genus 'Atta', subfamily: subfamily
      expect(decorator_helper.new(subfamily).send(:child_list, Genus.all, false))
        .to eq %{<div><span class="caption">Genus of <span>Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
    end

    it "formats an incertae sedis genera list" do
      genus = create_genus 'Atta', subfamily: subfamily, incertae_sedis_in: 'subfamily'
      expect(decorator_helper.new(subfamily).send(:child_list, [genus], false, incertae_sedis_in: 'subfamily'))
        .to eq %{<div><span class="caption">Genus <i>incertae sedis</i> in <span>Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
    end
  end

  describe "#collective_group_name_child_list" do
    let!(:genus) { create_genus 'Atta', subfamily: subfamily, status: 'collective group name' }

    it "formats a list of collective group names" do
      expect(decorator_helper.new(subfamily).send(:collective_group_name_child_list))
        .to eq %{<div><span class="caption">Collective group name in <span>Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
    end
  end

  describe "#child_list_query" do
    let!(:subfamily) { create :subfamily }
    let!(:atta) { create :genus, subfamily: subfamily }
    let!(:eciton) { create :genus, subfamily: subfamily, fossil: true }
    let!(:aneuretus) do
      create :genus, subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'
    end

    before { create :genus, subfamily: subfamily, status: 'synonym' }

    it "finds all genera for the taxon if there are no conditions" do
      results = decorator_helper.new(subfamily).send :child_list_query, :genera
      expect(results).to match_array [aneuretus, atta, eciton]

      results = decorator_helper.new(subfamily).send :child_list_query, :genera, fossil: true
      expect(results).to match_array [aneuretus, eciton]

      results = decorator_helper.new(subfamily).send :child_list_query, :genera, incertae_sedis_in: 'subfamily'
      expect(results).to match_array [aneuretus]
    end

    it "doesn't include invalid taxa" do
      results = decorator_helper.new(subfamily).send :child_list_query, :genera
      expect(results).to match_array [aneuretus, atta, eciton]
    end
  end
end
