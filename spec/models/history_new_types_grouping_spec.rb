# frozen_string_literal: true

require 'rails_helper'

# A different spelling, object taxon or subtype must start a separate line (group key), 2026-11-08.
describe HistoryPresenter, '#grouped_items with the types of #1598' do
  let(:protonym) { create :protonym }
  let(:taxon_a) { create :family }
  let(:taxon_b) { create :family }

  def lines
    described_class.new(HistoryItem.where(protonym: protonym)).grouped_items.map(&:items).map(&:size)
  end

  it 'keeps one line per misspelt spelling' do
    create :history_item, :misspelled_as, protonym: protonym, text_value: '<i>atrata</i>'
    create :history_item, :misspelled_as, protonym: protonym, text_value: '<i>atrata</i>'
    create :history_item, :misspelled_as, protonym: protonym, text_value: '<i>atratta</i>'
    expect(lines).to eq [2, 1]
  end

  it 'keeps one line per object taxon for material referred to' do
    create :history_item, :material_referred_to, protonym: protonym, object_taxon: taxon_a
    create :history_item, :material_referred_to, protonym: protonym, object_taxon: taxon_a
    create :history_item, :material_referred_to, protonym: protonym, object_taxon: taxon_b
    expect(lines).to eq [2, 1]
  end

  it 'keeps one line per subtype and object taxon for incertae sedis' do
    create :history_item, :incertae_sedis_in, protonym: protonym, object_taxon: taxon_a, subtype: 'IncertaeSedis'
    create :history_item, :incertae_sedis_in, protonym: protonym, object_taxon: taxon_a, subtype: 'UnidentifiableTaxon'
    create :history_item, :incertae_sedis_in, protonym: protonym, object_taxon: taxon_b, subtype: 'UnidentifiableTaxon'
    expect(lines).to eq [1, 1, 1]
  end

  it 'renders an unsaved item with a blank subtype instead of raising' do
    item = build :history_item, :incertae_sedis_in, subtype: nil
    expect(item).not_to be_valid
    expect { item.to_taxt }.not_to raise_error
  end
end
