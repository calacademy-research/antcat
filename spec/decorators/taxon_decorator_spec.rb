# frozen_string_literal: true

require 'rails_helper'

describe TaxonDecorator do
  include TestLinksHelpers

  subject(:decorated) { taxon.decorate }

  describe "#link_to_taxon_with_author_citation" do
    let(:taxon) { create :any_taxon }

    specify do
      expect(decorated.link_to_taxon_with_author_citation).to eq <<~HTML.squish
        #{taxon_link(taxon)} #{taxon.author_citation}
      HTML
    end
  end

  describe "#id_and_name_and_author_citation" do
    let(:taxon) { create :any_taxon }

    specify do
      expect(decorated.id_and_name_and_author_citation).to eq <<~HTML.squish
        <span><span class="text-sm text-gray-600">##{taxon.id}</span>
        #{taxon_link(taxon)}
        <span class="text-sm text-gray-600">#{taxon.author_citation}</span></span>
      HTML
    end
  end

  describe "#link_to_antwiki" do
    context 'when taxon is not a subgenus' do
      let(:taxon) { create :species }

      it 'builds the URL from the full name' do
        expect(decorated.link_to_antwiki).
          to eq %(<a class="external-link" href="https://www.antwiki.org/wiki/#{taxon.name.name.tr(' ', '_')}">AntWiki</a>)
      end
    end

    context 'when taxon is a subgenus' do
      let(:taxon) { create :subgenus, name_string: 'Camponotus (Forelophilus)' }

      it 'builds the URL from the subgenus epithet' do
        expect(decorated.link_to_antwiki).
          to eq %(<a class="external-link" href="https://www.antwiki.org/wiki/Forelophilus">AntWiki</a>)
      end
    end
  end

  describe "#link_to_hol" do
    context "without a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily }

      it 'does not render a link' do
        expect(decorated.link_to_hol).to eq nil
      end
    end

    context "with a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily, hol_id: 1234 }

      specify do
        expect(decorated.link_to_hol).
          to eq '<a class="external-link" href="http://hol.osu.edu/index.html?id=1234">HOL</a>'
      end
    end
  end

  describe "#link_to_antweb" do
    [:family, :tribe, :subtribe, :subgenus, :infrasubspecies].each do |rank|
      context "when taxon is a #{rank}" do
        let(:taxon) { build_stubbed rank }

        it 'does not render a link' do
          expect(taxon.decorate.link_to_antweb).to eq nil
        end
      end
    end

    context 'when taxon is a subfamily' do
      let(:taxon) { create :subfamily }

      specify do
        expect(taxon.decorate.link_to_antweb).
          to eq antweb_link_with_params("rank=subfamily&subfamily=#{taxon.name.name.downcase}&project=worldants")
      end
    end

    context 'when taxon is a genus' do
      let(:taxon) { create :genus, name_string: 'Atta' }

      specify do
        expect(taxon.decorate.link_to_antweb).to eq antweb_link_with_params('rank=genus&genus=atta&project=worldants')
      end
    end

    context 'when taxon is a species' do
      let(:taxon) { create :species, name_string: 'Atta major', genus: create(:genus, name_string: 'Atta') }

      specify do
        expect(taxon.decorate.link_to_antweb).
          to eq antweb_link_with_params('rank=species&genus=atta&species=major&project=worldants')
      end
    end

    context 'when taxon is a subspecies' do
      let(:genus) { create :genus, name_string: 'Atta' }
      let(:species) { create :species, name_string: 'Atta major', genus: genus }
      let(:taxon) { create :subspecies, name_string: 'Atta major minor', species: species, genus: genus }

      specify do
        expect(taxon.decorate.link_to_antweb).
          to eq antweb_link_with_params('rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants')
      end
    end

    def antweb_link_with_params params
      %(<a class="external-link" href="https://www.antweb.org/description.do?#{params}">AntWeb</a>)
    end
  end
end
