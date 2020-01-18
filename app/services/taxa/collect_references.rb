# TODO: Not all references are included, since this is more of an experiment.
# Most `Taxt::TAXTABLES` are not included.

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

      def taxt_content
        string = ''
        string << taxon.history_items.pluck(:taxt).join
        string << taxon.reference_sections.pluck(:references_taxt).join
        string << (taxon.type_taxt || '')
        string
      end

      def extract_ref_tags string
        string.scan(Taxt::REFERENCE_TAG_REGEX).flatten.compact.map(&:to_i).sort
      end
  end
end
