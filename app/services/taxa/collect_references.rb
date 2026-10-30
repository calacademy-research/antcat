# frozen_string_literal: true

module Taxa
  class CollectReferences
    include Service

    attr_private_initialize :taxon

    def call
      Reference.where(id: reference_ids)
    end

    private

      def reference_ids
        reference_ids_from_relations + reference_ids_from_taxts
      end

      def reference_ids_from_relations
        [
          taxon.authorship_reference.id,
          *taxon.history_items_for_taxon.relational.where.not(reference_id: nil).pluck(:reference_id)
        ]
      end

      def reference_ids_from_taxts
        Taxt.extract_ids_from_reference_tags(taxt_content).sort
      end

      # Every taxt shown on the catalog page, reference sections' titles and subtitles included. For visitors
      # without the hidden notes, so that a reference cited only in a hidden note is not listed.
      def taxt_content
        taxts = []
        taxts.concat taxon.history_items_for_taxon.pluck(:taxt)
        taxts.concat taxon.reference_sections.pluck(:title_taxt, :subtitle_taxt, :references_taxt).flatten
        taxts << taxon.protonym.primary_type_information_taxt
        taxts << taxon.protonym.secondary_type_information_taxt
        taxts << taxon.protonym.type_notes_taxt
        taxts << taxon.protonym.notes_taxt
        taxts.compact!
        taxts.map! { Taxt.remove_hidden_notes(it) } unless Current.signed_in
        taxts.join(' ')
      end
  end
end
