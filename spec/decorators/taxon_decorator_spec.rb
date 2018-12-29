require 'spec_helper'

describe TaxonDecorator do
  let(:taxon) { build_stubbed :family }
  let(:decorated) { taxon.decorate }

  describe "#link_to_taxon" do
    specify do
      expect(decorated.link_to_taxon).to eq <<~HTML.squish
        <a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>
      HTML
    end
  end

  describe "#id_and_name_and_author_citation" do
    specify do
      expect(decorated.id_and_name_and_author_citation).to eq <<~HTML.squish
        <span><small class="gray">##{taxon.id}</small>
        <a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>
        <small class="gray">#{taxon.author_citation}</small></span>
      HTML
    end
  end

  describe "#link_to_antwiki" do
    let(:taxon) { create :species }

    it "can link to species" do
      name = taxon.name_cache.tr(' ', '_')
      expect(decorated.link_to_antwiki).to eq(
        %(<a class="external-link" href="http://www.antwiki.org/wiki/#{name}">AntWiki</a>)
      )
    end
  end

  describe "#link_to_hol" do
    context "without a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily }

      it "doesn't link" do
        expect(decorated.link_to_hol).to be nil
      end
    end

    context "with a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily, hol_id: 1234 }

      it "links" do
        expect(decorated.link_to_hol).to eq(
          '<a class="external-link" href="http://hol.osu.edu/index.html?id=1234">HOL</a>'
        )
      end
    end
  end

  describe "#link_to_antweb" do
    it "handles subfamilies" do
      taxon = build_stubbed :subfamily
      expect(taxon.decorate.link_to_antweb).
        to eq %(<a class="external-link" href="http://www.antweb.org/description.do?rank=subfamily&subfamily=#{taxon.name.name.downcase}&project=worldants">AntWeb</a>)
    end

    it "outputs nothing for tribes" do
      taxon = build_stubbed :tribe
      expect(taxon.decorate.link_to_antweb).to be_nil
    end

    it "handles genera" do
      taxon = create_genus 'Atta'
      expect(taxon.decorate.link_to_antweb).
        to eq '<a class="external-link" href="http://www.antweb.org/description.do?rank=genus&genus=atta&project=worldants">AntWeb</a>'
    end

    it "outputs nothing for subgenera" do
      taxon = build_stubbed :subgenus
      expect(taxon.decorate.link_to_antweb).to be_nil
    end

    it "handles species" do
      taxon = create_species 'Atta major', genus: create_genus('Atta')
      expect(taxon.decorate.link_to_antweb).
        to eq '<a class="external-link" href="http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants">AntWeb</a>'
    end

    it "handles subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      taxon = create_subspecies 'Atta major minor', species: species, genus: genus
      expect(taxon.decorate.link_to_antweb).
        to eq '<a class="external-link" href="http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants">AntWeb</a>'
    end

    it "just returns nil for subspecies without species" do
      taxon = build_stubbed :subspecies, species: nil
      expect(taxon.decorate.link_to_antweb).to be_nil
    end
  end
end
