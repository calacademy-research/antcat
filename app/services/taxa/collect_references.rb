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
          taxon.authorship_reference.id
        ]
      end

      def reference_ids_from_taxts
        Taxt.extract_ids_from_ref_tags(taxt_content).sort
      end

      def taxt_content
        string = []
        string << taxon.history_items.pluck(:taxt).join
        string << taxon.reference_sections.pluck(:references_taxt).join
        string << (taxon.protonym.primary_type_information_taxt || '')
        string << (taxon.protonym.secondary_type_information_taxt || '')
        string << (taxon.protonym.type_notes_taxt || '')
        string << (taxon.protonym.notes_taxt || '')
        string.join
      end
  end
end
