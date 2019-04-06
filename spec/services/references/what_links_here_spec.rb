require "spec_helper"

describe References::WhatLinksHere do
  let(:reference) { create :article_reference }

  describe "#call" do
    context 'when there are no references' do
      specify { expect(reference.what_links_here).to eq [] }
    end

    context 'when there are taxt references' do
      specify do
        citation = create :citation, reference: reference, notes_taxt: "{ref #{reference.id}}"
        protonym = create :protonym, authorship: citation
        taxon = create :genus,
          protonym: protonym,
          type_taxt: "{ref #{reference.id}}",
          headline_notes_taxt: "{ref #{reference.id}}"
        history_item = taxon.history_items.create! taxt: "{ref #{reference.id}}"
        reference_section = create :reference_section,
          title_taxt: "{ref #{reference.id}}",
          subtitle_taxt: "{ref #{reference.id}}",
          references_taxt: "{ref #{reference.id}}"

        expect(reference.reload.what_links_here).to match_array [
          { table: 'taxa',                id: taxon.id,             field: :type_taxt },
          { table: 'taxa',                id: taxon.id,             field: :headline_notes_taxt },
          { table: 'citations',           id: citation.id,          field: :notes_taxt },
          { table: 'citations',           id: citation.id,          field: :reference_id },
          { table: 'reference_sections',  id: reference_section.id, field: :title_taxt },
          { table: 'reference_sections',  id: reference_section.id, field: :subtitle_taxt },
          { table: 'reference_sections',  id: reference_section.id, field: :references_taxt },
          { table: 'taxon_history_items', id: history_item.id,      field: :taxt }
        ]
      end
    end

    describe "references in reference fields" do
      let!(:taxon) { create :family }
      let!(:nested_reference) { create :nested_reference, nesting_reference: reference }

      before do
        taxon.protonym.authorship.update! reference: reference
      end

      specify do
        expect(reference.reload.what_links_here).to match_array [
          { table: 'citations',  id: taxon.protonym.authorship.id, field: :reference_id },
          { table: 'references', id: nested_reference.id,          field: :nesting_reference_id }
        ]
      end
    end
  end
end
