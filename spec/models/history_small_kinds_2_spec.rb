# frozen_string_literal: true

require 'rails_helper'

# Small species-group kinds (2026-11-14): each renders as the free text did.
describe HistoryItem do
  let(:protonym) { create :protonym }
  let(:taxon) { create :family }

  describe '#to_taxt' do
    History::Definitions::UNRESOLVED_HOMONYM_KINDS.each do |subtype, kind|
      it "renders an unresolved junior #{kind} homonym, with and without a citation" do
        bare = create :history_item, :unresolved_junior_homonym_of, protonym: protonym, subtype: subtype, object_taxon: taxon
        cited = create :history_item, :unresolved_junior_homonym_of, :with_reference, protonym: protonym, subtype: subtype,
          object_taxon: taxon
        expect(bare.to_taxt).to eq "[Unresolved junior #{kind} homonym of #{Taxt.taxac(taxon.id)}.]"
        expect(cited.to_taxt).to eq "[Unresolved junior #{kind} homonym of #{Taxt.taxac(taxon.id)} (#{cited.citation_taxt}).]"
      end
    end

    it 'renders an unnecessary replacement name' do
      item = create :history_item, :unnecessary_replacement_name_for, protonym: protonym, object_taxon: taxon
      expect(item.to_taxt).to eq "Unnecessary replacement name for #{Taxt.taxac(taxon.id)}."
    end

    it 'renders unidentifiable taxon, subgenus indeterminate and duplicated in' do
      a = create :history_item, :unidentifiable_taxon, protonym: protonym
      b = create :history_item, :subgenus_indeterminate, protonym: protonym
      c = create :history_item, :duplicated_in, protonym: protonym
      expect(a.to_taxt).to eq "Unidentifiable taxon: #{a.citation_taxt}."
      expect(b.to_taxt).to eq "Subgenus indeterminate: #{b.citation_taxt}."
      expect(c.to_taxt).to eq "[Duplicated in #{c.citation_taxt}.]"
    end

    it 'renders a nomen nudum citation' do
      item = create :history_item, :nomen_nudum_citation, protonym: protonym
      expect(item.to_taxt).
        to eq "[{unmissing <i>Camponotus maculatus cognatodichrous</i>} #{item.citation_taxt}. <i>Nomen nudum</i>.]"
    end
  end

  describe 'validation' do
    it 'requires a known subtype and an object for unresolved homonyms' do
      expect(build(:history_item, :unresolved_junior_homonym_of, protonym: protonym, subtype: 'Tertiary')).not_to be_valid
      expect(build(:history_item, :unresolved_junior_homonym_of, protonym: protonym, object_taxon: nil)).not_to be_valid
    end

    it 'requires the name for a nomen nudum citation' do
      expect(build(:history_item, :nomen_nudum_citation, protonym: protonym, text_value: nil)).not_to be_valid
    end

    it 'renders an unsaved unresolved homonym with a blank subtype instead of raising' do
      item = build :history_item, :unresolved_junior_homonym_of, subtype: nil
      expect { item.to_taxt }.not_to raise_error
    end
  end

  describe 'grouping on the page' do
    def lines
      HistoryPresenter.new(described_class.where(protonym: protonym)).grouped_items.map(&:items).map(&:size)
    end

    it 'groups duplicated-in citations into one line' do
      create :history_item, :duplicated_in, protonym: protonym
      create :history_item, :duplicated_in, protonym: protonym
      expect(lines).to eq [2]
    end

    it 'keeps one line per name for nomen nudum citations' do
      create :history_item, :nomen_nudum_citation, protonym: protonym, text_value: '<i>Xus a</i>'
      create :history_item, :nomen_nudum_citation, protonym: protonym, text_value: '<i>Xus a</i>'
      create :history_item, :nomen_nudum_citation, protonym: protonym, text_value: '<i>Xus b</i>'
      expect(lines).to eq [2, 1]
    end
  end
end
