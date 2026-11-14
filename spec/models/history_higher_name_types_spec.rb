# frozen_string_literal: true

require 'rails_helper'

# Genus- and family-group types (2026-11-14): the line starts with the protonym's terminal taxon, as the
# free text did ("Pheidole in Myrmicinae, Pheidolini: ...").
describe HistoryItem do
  let(:protonym) { create :protonym }
  let(:subject_tag) { Taxt.prott(protonym.id) }
  let(:taxon_a) { create :family }
  let(:taxon_b) { create :family }

  describe '#to_taxt' do
    it 'renders placement in' do
      item = create :history_item, :placement_in, protonym: protonym, taxt: "#{Taxt.tax(taxon_a.id)}, #{Taxt.tax(taxon_b.id)}"
      expect(item.to_taxt).
        to eq "#{subject_tag} in #{Taxt.tax(taxon_a.id)}, #{Taxt.tax(taxon_b.id)}: #{item.citation_taxt}."
    end

    it 'renders incertae sedis in' do
      item = create :history_item, :placement_incertae_sedis_in, protonym: protonym, object_taxon: taxon_a
      expect(item.to_taxt).
        to eq "#{subject_tag} <i>incertae sedis</i> in #{Taxt.tax(taxon_a.id)}: #{item.citation_taxt}."
    end

    it 'renders as genus' do
      item = create :history_item, :as_genus, protonym: protonym
      expect(item.to_taxt).to eq "#{subject_tag} as genus: #{item.citation_taxt}."
    end

    History::Definitions::AS_RANK_OF_RANKS.each do |subtype, rank|
      it "renders as #{rank} of" do
        item = create :history_item, :as_rank_of, protonym: protonym, subtype: subtype, object_taxon: taxon_a
        expect(item.to_taxt).to eq "#{subject_tag} as #{rank} of #{Taxt.tax(taxon_a.id)}: #{item.citation_taxt}."
      end
    end

    History::Definitions::AS_SYNONYM_OF_KINDS.each do |subtype, kind|
      it "renders as #{kind} synonym of" do
        item = create :history_item, :as_synonym_of, protonym: protonym, subtype: subtype, object_taxon: taxon_a
        expect(item.to_taxt).
          to eq "#{subject_tag} as #{kind} synonym of #{Taxt.tax(taxon_a.id)}: #{item.citation_taxt}."
      end
    end

    it 'uses {prottac} for the subject with force_author_citation' do
      item = create :history_item, :as_genus, protonym: protonym, force_author_citation: true
      expect(item.to_taxt).to eq "#{Taxt.prottac(protonym.id)} as genus: #{item.citation_taxt}."
    end
  end

  describe 'validation' do
    it 'requires the placement for placement in' do
      expect(build(:history_item, :placement_in, taxt: nil)).not_to be_valid
    end

    it 'requires a known subtype' do
      expect(build(:history_item, :as_rank_of, subtype: 'Genus')).not_to be_valid
      expect(build(:history_item, :as_synonym_of, subtype: 'Other')).not_to be_valid
    end

    it 'does not allow taxt on the other types' do
      expect(build(:history_item, :as_genus, taxt: 'x')).not_to be_valid
    end

    it 'renders an unsaved item with a blank subtype instead of raising' do
      item = build :history_item, :as_synonym_of, subtype: nil
      expect(item).not_to be_valid
      expect { item.to_taxt }.not_to raise_error
    end
  end

  describe 'grouping on the page (HistoryPresenter#grouped_items)' do
    def lines
      HistoryPresenter.new(HistoryItem.where(protonym: protonym)).grouped_items.map(&:items).map(&:size)
    end

    it 'keeps one line per placement' do
      create :history_item, :placement_in, protonym: protonym, taxt: Taxt.tax(taxon_a.id)
      create :history_item, :placement_in, protonym: protonym, taxt: Taxt.tax(taxon_a.id)
      create :history_item, :placement_in, protonym: protonym, taxt: "#{Taxt.tax(taxon_a.id)}, #{Taxt.tax(taxon_b.id)}"
      expect(lines).to eq [2, 1]
    end

    it 'keeps one line per kind and object for synonyms' do
      create :history_item, :as_synonym_of, protonym: protonym, subtype: 'Junior', object_taxon: taxon_a
      create :history_item, :as_synonym_of, protonym: protonym, subtype: 'Junior', object_taxon: taxon_a
      create :history_item, :as_synonym_of, protonym: protonym, subtype: 'Senior', object_taxon: taxon_a
      create :history_item, :as_synonym_of, protonym: protonym, subtype: 'Junior', object_taxon: taxon_b
      expect(lines).to eq [2, 1, 1]
    end

    it 'keeps one line per object for incertae sedis' do
      create :history_item, :placement_incertae_sedis_in, protonym: protonym, object_taxon: taxon_a
      create :history_item, :placement_incertae_sedis_in, protonym: protonym, object_taxon: taxon_a
      create :history_item, :placement_incertae_sedis_in, protonym: protonym, object_taxon: taxon_b
      expect(lines).to eq [2, 1]
    end

    it 'keeps lines with and without the author citation apart' do
      create :history_item, :as_genus, protonym: protonym
      create :history_item, :as_genus, protonym: protonym, force_author_citation: true
      expect(lines).to eq [1, 1]
    end

    it 'keeps one line per rank and object' do
      create :history_item, :as_rank_of, protonym: protonym, subtype: 'Subgenus', object_taxon: taxon_a
      create :history_item, :as_rank_of, protonym: protonym, subtype: 'Tribe', object_taxon: taxon_a
      expect(lines).to eq [1, 1]
    end
  end
end
