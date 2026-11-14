# frozen_string_literal: true

require 'rails_helper'

# A note printed right after a citation, kept as printed (2026-11-14).
describe HistoryItem do
  describe '#citation_taxt with a citation note' do
    it 'appends the note after the pages' do
      item = create :history_item, :status_as_species, citation_note: '(see note in bibliography)'
      expect(item.citation_taxt).to eq "#{Taxt.ref(item.reference_id)}: #{item.pages} (see note in bibliography)"
    end

    it 'keeps taxt tags in a bracketed note' do
      taxon = create :family
      item = create :history_item, :as_genus, citation_note: "[#{Taxt.tax(taxon.id)}]"
      expect(item.to_taxt).to end_with ": #{Taxt.ref(item.reference_id)}: #{item.pages} [#{Taxt.tax(taxon.id)}]."
    end

    it 'leaves the citation alone without a note' do
      item = create :history_item, :status_as_species
      expect(item.citation_taxt).to eq "#{Taxt.ref(item.reference_id)}: #{item.pages}"
    end
  end

  describe 'grouped citations' do
    it 'keeps each note with its own citation' do
      protonym = create :protonym
      first = create :history_item, :status_as_species, protonym: protonym, citation_note: '[provisional]'
      second = create :history_item, :status_as_species, protonym: protonym
      grouped = HistoryPresenter.new(described_class.where(protonym: protonym)).grouped_items.first
      expect(grouped.taxt).to include(first.citation_taxt, second.citation_taxt)
      expect(first.citation_taxt).to end_with ' [provisional]'
      expect(second.citation_taxt).not_to include '['
    end
  end

  describe 'validation of citation_note' do
    # A saved protonym: an unsaved one has no id, which another validation reads as "object is the protonym".
    let(:protonym) { create :protonym }

    it 'accepts square brackets and parentheses' do
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[provisional]')).to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '(diagnosis, redescription)')).to be_valid
    end

    it 'accepts taxt tags and one level of parentheses' do
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[{tax 1}]')).to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[{unmissing <i>Myrmicidae</i>}]')).to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[{missing <i>Attidae</i>}]')).to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[by implication (as type-genus)]')).to be_valid
    end

    it 'refuses other forms' do
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: 'provisional')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[a; b]')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '(a) free text (b)')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '(x] [y)')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '(see {foo)')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: '[<b>x</b>]')).not_to be_valid
      expect(build(:history_item, :status_as_species, protonym: protonym, citation_note: "[#{'x' * 300}]")).not_to be_valid
    end

    it 'refuses a note with a reference but no pages' do
      expect(build(:history_item, :status_as_species, protonym: protonym, pages: nil, citation_note: '[provisional]')).not_to be_valid
    end

    it 'refuses a note on a free-text item' do
      expect(build(:history_item, protonym: protonym, taxt: 'Text.', citation_note: '[provisional]')).not_to be_valid
    end

    it 'refuses a note without a reference' do
      expect(build(:history_item, :unavailable_name, protonym: protonym, citation_note: '[provisional]')).not_to be_valid
    end
  end
end
