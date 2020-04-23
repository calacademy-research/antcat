# frozen_string_literal: true

require 'rails_helper'

describe TableRefDecorator do
  include TestLinksHelpers

  subject(:decorated) { described_class.new(table_ref) }

  let(:id) { object.id }
  let(:table_ref) { TableRef.new(table, "_field", id) }

  context "when table is `citations`" do
    let(:table) { "citations" }
    let(:object) { create(:protonym).authorship }

    specify { expect(decorated.item_link).to eq id }
    specify { expect(decorated.owner_link).to eq %(Protonym: #{protonym_link(object.protonym)}) }
  end

  context "when table is `protonyms`" do
    let(:table) { "protonyms" }
    let!(:object) { create :protonym }

    specify { expect(decorated.item_link).to eq %(<a href="/protonyms/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq %(Protonym: #{protonym_link(object)}) }
  end

  context "when table is `reference_sections`" do
    let(:table) { "reference_sections" }
    let!(:object) { create :reference_section }

    specify { expect(decorated.item_link).to eq %(<a href="/reference_sections/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq taxon_link(object.taxon) }
  end

  context "when table is `references`" do
    let(:table) { "references" }
    let!(:object) { create :any_reference }

    specify { expect(decorated.item_link).to eq %(<a href="/references/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq object.decorate.expandable_reference }
  end

  context "when table is `taxa`" do
    let(:table) { "taxa" }
    let!(:object) { create :family }

    specify { expect(decorated.item_link).to eq %(<a href="/catalog/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq taxon_link(object) }
  end

  context "when table is `taxon_history_items`" do
    let(:table) { "taxon_history_items" }
    let!(:object) { create :taxon_history_item }

    specify { expect(decorated.item_link).to eq %(<a href="/taxon_history_items/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq taxon_link(object.taxon) }
  end
end
