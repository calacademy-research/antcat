# frozen_string_literal: true

require 'rails_helper'

describe WhatLinksHereItemDecorator do
  include TestLinksHelpers

  subject(:decorated) { described_class.new(what_links_here_item) }

  let(:id) { object.id }
  let(:what_links_here_item) { WhatLinksHereItem.new(table, "_field", id) }

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
    let!(:object) { create :any_taxon }

    specify { expect(decorated.item_link).to eq %(<a href="/catalog/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq taxon_link(object) }
  end

  context "when table is `taxon_history_items`" do
    let(:table) { "taxon_history_items" }
    let!(:object) { create :history_item }

    specify { expect(decorated.item_link).to eq %(<a href="/taxon_history_items/#{id}">#{id}</a>) }
    specify { expect(decorated.owner_link).to eq %(Protonym: #{protonym_link(object.protonym)}) }
  end

  context "when table is `type_names`" do
    let(:table) { "type_names" }
    let(:object) { create(:protonym, :with_type_name).type_name }

    specify { expect(decorated.item_link).to eq id }
    specify { expect(decorated.owner_link).to eq %(Protonym: #{protonym_link(object.protonym)}) }
  end

  context "when table is unknown" do
    let(:table) { "pizzas" }
    let(:object) { create :activity }

    specify { expect { decorated.item_link }.to raise_error('unknown table pizzas') }
  end

  context "when owner is unknown" do
    let(:table) { "taxa" }
    let(:object) { create :activity }

    before do
      allow(what_links_here_item).to receive(:owner).and_return(object)
    end

    specify { expect { decorated.owner_link }.to raise_error('unknown owner Activity') }
  end
end
