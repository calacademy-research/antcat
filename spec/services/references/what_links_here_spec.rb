require "spec_helper"

describe References::WhatLinksHere do
  let(:reference) { create :article_reference }

  describe "#call" do
    it "recognizes various uses of this reference in taxt" do
      citation = create :citation, reference: reference, notes_taxt: "{ref #{reference.id}}"
      protonym = create :protonym, authorship: citation
      taxon = create :genus,
        protonym: protonym,
        type_taxt: "{ref #{reference.id}}",
        headline_notes_taxt: "{ref #{reference.id}}",
        genus_species_header_notes_taxt: "{ref #{reference.id}}"
      history_item = taxon.history_items.create! taxt: "{ref #{reference.id}}"
      reference_section = create :reference_section,
        title_taxt: "{ref #{reference.id}}",
        subtitle_taxt: "{ref #{reference.id}}",
        references_taxt: "{ref #{reference.id}}"
      nested_reference = create :nested_reference, nesting_reference: reference

      results = reference.reload.what_links_here
      expect(results).to match_array [
        { table: 'taxa',                id: taxon.id,             field: :type_taxt },
        { table: 'taxa',                id: taxon.id,             field: :headline_notes_taxt },
        { table: 'taxa',                id: taxon.id,             field: :genus_species_header_notes_taxt },
        { table: 'citations',           id: citation.id,          field: :notes_taxt },
        { table: 'citations',           id: citation.id,          field: :reference_id },
        { table: 'reference_sections',  id: reference_section.id, field: :title_taxt },
        { table: 'reference_sections',  id: reference_section.id, field: :subtitle_taxt },
        { table: 'reference_sections',  id: reference_section.id, field: :references_taxt },
        { table: 'references',          id: nested_reference.id,  field: :nesting_reference_id },
        { table: 'taxon_history_items', id: history_item.id,      field: :taxt }
      ]
    end

    it "has no references, if alone" do
      expect(reference.what_links_here.size).to eq 0
    end

    describe "references in reference fields" do
      let!(:eciton) { create_genus 'Eciton' }

      before { eciton.protonym.authorship.update! reference_id: reference.id }

      it "has a reference if it's a protonym's authorship's reference" do
        expect(reference.what_links_here).to match_array [
          { table: 'citations', field: :reference_id, id: eciton.protonym.authorship.id }
        ]
      end
    end

    describe "references in taxt" do
      let!(:eciton) { create_genus 'Eciton' }

      before { eciton.update_attribute :type_taxt, "{ref #{reference.id}}" }

      it "returns references in taxt" do
        expect(reference.what_links_here).to match_array [
          { table: 'taxa', field: :type_taxt, id: eciton.id }
        ]
      end
    end
  end
end
