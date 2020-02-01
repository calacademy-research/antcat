module Taxa
  class CollectReferences
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      Reference.where(id: reference_ids)
    end

    private

      attr_reader :taxon

      def reference_ids
        reference_ids_from_relations + reference_ids_from_taxts
      end

      def reference_ids_from_relations
        [
          taxon.authorship_reference.id
        ]
      end

      def reference_ids_from_taxts
        extract_ref_tags(taxt_content)
      end

      # TODO: Include `taxa.protonym.notes_taxt` once it has been moved from the `citations` table.
      def taxt_content
        string = ''
        string << taxon.history_items.pluck(:taxt).join
        string << taxon.reference_sections.pluck(:references_taxt).join
        string << (taxon.type_taxt || '')
        string << (taxon.headline_notes_taxt || '')
        string << (taxon.protonym.primary_type_information_taxt || '')
        string << (taxon.protonym.secondary_type_information_taxt || '')
        string << (taxon.protonym.type_notes_taxt || '')
        string
      end

      def extract_ref_tags string
        string.scan(Taxt::REF_TAG_REGEX).flatten.compact.map(&:to_i).sort
      end
  end
end
