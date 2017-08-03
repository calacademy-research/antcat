require "spec_helper"

describe TaxonDecorator::ChildList do
  let(:decorator_helper) { TaxonDecorator::ChildList }
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
    it "formats a list of collective group names" do
      genus = create_genus 'Atta', subfamily: subfamily, status: 'collective group name'
      expect(decorator_helper.new(subfamily).send(:collective_group_name_child_list))
        .to eq %{<div><span class="caption">Collective group name in <span>Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
    end
  end

  describe "#child_list_query" do
    let!(:subfamily) { create :subfamily, name: create(:name, name: 'Dolichoderinae') }

    it "finds all genera for the taxon if there are no conditions" do
      create :genus, name: create(:name, name: 'Atta'),
        subfamily: subfamily
      create :genus, name: create(:name, name: 'Eciton'),
        subfamily: subfamily, fossil: true
      create :genus, name: create(:name, name: 'Aneuretus'),
        subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'

      results = decorator_helper.new(subfamily).send :child_list_query, :genera
      expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Atta', 'Eciton']

      results = decorator_helper.new(subfamily).send :child_list_query, :genera, fossil: true
      expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Eciton']

      results = decorator_helper.new(subfamily).send :child_list_query, :genera, incertae_sedis_in: 'subfamily'
      expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus']
    end

    it "doesn't include invalid taxa" do
      create :genus, name: create(:name, name: 'Atta'),
        subfamily: subfamily, status: 'synonym'
      create :genus, name: create(:name, name: 'Eciton'),
        subfamily: subfamily, fossil: true
      create :genus, name: create(:name, name: 'Aneuretus'),
        subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'

      results = decorator_helper.new(subfamily).send :child_list_query, :genera
      expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Eciton']
    end
  end
end
