require 'spec_helper'

describe TableRefDecorator do
  let(:id) { object.id }
  let(:table_ref) { TableRef.new(table, "_field", id) }
  let(:decorated) { described_class.new(table_ref) }

  context "when table is `citations`" do
    let!(:table) { "citations" }
    let!(:protonym) { create :protonym }
    let!(:object) { protonym.authorship }
    let!(:taxon) { create :family, protonym: protonym }
    let!(:reference) { object.reference }

    specify { expect(decorated.item_link).to eq id }
    specify do
      expect(decorated.related_links).to eq taxon.link_to_taxon
    end

    context 'when citation has a protonym that has many taxa' do
      let!(:second_taxon) { create :family, protonym: protonym }

      specify do
        expected = taxon.link_to_taxon << ", " << second_taxon.link_to_taxon
        expect(decorated.related_links).to eq expected
      end
    end
  end

  context "when table is `protonyms`" do
    let!(:table) { "protonyms" }
    let!(:object) { create :protonym }
    let!(:name) { object.name }

    specify { expect(decorated.item_link).to eq %(<a href="/protonyms/#{id}">#{id}</a>) }
    specify { expect(decorated.related_links).to eq %(<a href="/protonyms/#{id}">Protonym: #{name.name_html}</a>) }
  end

  context "when table is `reference_sections`" do
    let!(:table) { "reference_sections" }
    let!(:object) { create :reference_section }
    let!(:taxon) { object.taxon }

    specify { expect(decorated.item_link).to eq %(<a href="/reference_sections/#{id}">#{id}</a>) }
    specify { expect(decorated.related_links).to eq taxon.link_to_taxon }
  end

  context "when table is `references`" do
    let!(:table) { "references" }
    let!(:object) { create :article_reference }
    let!(:reference) { object }

    specify { expect(decorated.item_link).to eq %(<a href="/references/#{id}">#{id}</a>) }
    specify { expect(decorated.related_links).to eq reference.decorate.expandable_reference }
  end

  context "when table is `taxa`" do
    let!(:table) { "taxa" }
    let!(:object) { create :family }
    let!(:taxon) { object }

    specify { expect(decorated.item_link).to eq %(<a href="/catalog/#{id}">#{id}</a>) }
    specify { expect(decorated.related_links).to eq taxon.link_to_taxon }
  end

  context "when table is `taxon_history_items`" do
    let!(:table) { "taxon_history_items" }
    let!(:object) { create :taxon_history_item }
    let!(:taxon) { object.taxon }

    specify { expect(decorated.item_link).to eq %(<a href="/taxon_history_items/#{id}">#{id}</a>) }
    specify { expect(decorated.related_links).to eq taxon.link_to_taxon }
  end
end
