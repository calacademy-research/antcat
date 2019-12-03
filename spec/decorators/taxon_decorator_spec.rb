require 'rails_helper'

describe TaxonDecorator do
  let(:taxon) { build_stubbed :family }
  let(:decorated) { taxon.decorate }

  describe "#id_and_name_and_author_citation" do
    specify do
      expect(decorated.id_and_name_and_author_citation).to eq <<~HTML.squish
        <span><small class="gray">##{taxon.id}</small>
        <a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>
        <small class="gray">#{taxon.author_citation}</small></span>
      HTML
    end
  end

  describe "#format_type_taxt" do
    context 'when `type_taxt` starts with comma' do
      let(:taxon) { build_stubbed :family, type_taxt: ', pizza' }

      specify { expect(decorated.format_type_taxt).to eq ', pizza' }
    end

    context 'when `type_taxt` starts with comma' do
      let(:taxon) { build_stubbed :family, type_taxt: 'pizza' }

      specify { expect(decorated.format_type_taxt).to eq ' pizza' }
    end
  end

  describe "#link_to_antwiki" do
    let(:taxon) { build_stubbed :species }

    it "can link to species" do
      name = taxon.name.name.tr(' ', '_')
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

      query_params = "rank=subfamily&subfamily=#{taxon.name.name.downcase}&project=worldants"
      expect(taxon.decorate.link_to_antweb).
        to eq %(<a class="external-link" href="http://www.antweb.org/description.do?#{query_params}">AntWeb</a>)
    end

    it "outputs nothing for tribes" do
      taxon = build_stubbed :tribe
      expect(taxon.decorate.link_to_antweb).to be_nil
    end

    it "handles genera" do
      taxon = create :genus, name_string: 'Atta'

      query_params = 'rank=genus&genus=atta&project=worldants'
      expect(taxon.decorate.link_to_antweb).
        to eq %(<a class="external-link" href="http://www.antweb.org/description.do?#{query_params}">AntWeb</a>)
    end

    it "outputs nothing for subgenera" do
      taxon = build_stubbed :subgenus
      expect(taxon.decorate.link_to_antweb).to be_nil
    end

    it "handles species" do
      taxon = create :species, name_string: 'Atta major', genus: create(:genus, name_string: 'Atta')

      query_params = 'rank=species&genus=atta&species=major&project=worldants'
      expect(taxon.decorate.link_to_antweb).
        to eq %(<a class="external-link" href="http://www.antweb.org/description.do?#{query_params}">AntWeb</a>)
    end

    it "handles subspecies" do
      genus = create :genus, name_string: 'Atta'
      species = create :species, name_string: 'Atta major', genus: genus
      taxon = create :subspecies, name_string: 'Atta major minor', species: species, genus: genus

      query_params = 'rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants'
      expect(taxon.decorate.link_to_antweb).
        to eq %(<a class="external-link" href="http://www.antweb.org/description.do?#{query_params}">AntWeb</a>)
    end
  end
end
