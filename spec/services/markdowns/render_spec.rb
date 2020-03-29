# frozen_string_literal: true

# TODO: Move most specs here to `parse_antcat_hooks_spec.rb`.

require 'rails_helper'

describe Markdowns::Render do
  include TestLinksHelpers

  describe "#call" do
    it "formats some basic markdown" do
      markdown = <<~MARKDOWN
        ###Header
        * A list item

        *italics* **bold**
      MARKDOWN

      expect(described_class[markdown]).to eq <<~HTML
        <h3>Header</h3>

        <ul>
        <li>A list item</li>
        </ul>

        <p><em>italics</em> <strong>bold</strong></p>
      HTML
    end

    it "formats taxon ids" do
      taxon = create :species
      markdown = "%taxon#{taxon.id}"
      expect(described_class[markdown]).to eq "<p>#{taxon_link(taxon)}</p>\n"
    end

    describe "reference ids" do
      context "when reference exists" do
        let(:reference) { create :any_reference }
        let(:markdown) { "%reference#{reference.id}" }
        let(:taxt_markdown) { "{ref #{reference.id}}" }

        it "links the reference" do
          expected = "<p>#{reference.decorate.expandable_reference}</p>\n"
          expect(reference.decorate.expandable_reference.blank?).to eq false
          expect(described_class[markdown]).to eq expected
          expect(described_class[taxt_markdown]).to eq expected
        end
      end

      context "when reference does not exists" do
        let(:markdown) { "%reference9999999" }
        let(:taxt_markdown) { '{ref 9999999}' }

        it "renders an error message" do
          expected = "CANNOT FIND REFERENCE WITH ID 9999999"
          expect(described_class[markdown]).to include expected
          expect(described_class[taxt_markdown]).to include expected
        end
      end
    end

    it "formats GitHub links" do
      markdown = "%github5"

      expected = %(<p><a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a></p>\n)
      expect(described_class[markdown]).to eq expected
    end

    it "formats user links" do
      user = create :user
      markdown = "@user#{user.id}"

      results = described_class[markdown]
      expect(results).to include user.name
      expect(results).to include "users/#{user.id}"
    end

    describe 'database script links' do
      context 'when database script exists' do
        specify do
          expect(described_class["%dbscript:OrphanedProtonyms"]).
            to eq %(<p><a href="/database_scripts/orphaned_protonyms">Orphaned protonyms</a> <span class="white-label rounded-badge">list</span></p>\n)
        end
      end

      context 'when database script does not exist' do
        specify do
          expect(described_class["%dbscript:BestPizzas"]).
            to eq %(<p><a href="/database_scripts/best_pizzas">Error: Could not find database script with class name &#39;BestPizzas&#39;</a> </p>\n)
        end
      end
    end
  end
end
