# frozen_string_literal: true

module MetaTags
  class TaxonMetaTagContent
    include Service

    attr_private_initialize :taxon

    def call
      meta_tag_content
    end

    private

      def meta_tag_content
        [
          family,
          taxon_with_author_citation,
          status
        ].join('. ')
      end

      def family
        return 'Excluded from Formicidae' if taxon.excluded_from_formicidae?
        "Family: Formicidae"
      end

      def taxon_with_author_citation
        "#{taxon.type}: #{taxon.name_cache} #{taxon.author_citation}"
      end

      def status
        "Status: #{taxon.status}."
      end
  end
end
