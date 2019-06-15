module Taxa
  class TaxonStatus
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      parts = []
      parts << "<i>incertae sedis</i> in #{incertae_sedis_in}" if incertae_sedis_in
      parts << main_status
      parts << 'ichnotaxon' if ichnotaxon?
      parts.join(', ').html_safe
    end

    private

      attr_reader :taxon

      delegate :incertae_sedis_in, :homonym?, :homonym_replaced_by,
        :unresolved_homonym?, :current_valid_taxon, :current_valid_taxon_including_synonyms, :nomen_nudum?,
        :synonym?, :obsolete_combination?, :original_combination?, :unavailable_misspelling?,
        :unavailable_uncategorized?, :invalid?, :ichnotaxon?, to: :taxon

      def main_status
        if homonym? && homonym_replaced_by
          "homonym replaced by #{homonym_replaced_by.decorate.link_to_taxon_with_author_citation}"
        elsif unresolved_homonym?
          if current_valid_taxon_including_synonyms
            "unresolved junior homonym, junior synonym of current valid taxon #{format_senior_synonym}"
          else
            "unresolved junior homonym"
          end
        elsif nomen_nudum?
          "<i>nomen nudum</i>"
        elsif synonym?
          "junior synonym of current valid taxon #{format_senior_synonym}"
        elsif obsolete_combination?
          "an obsolete combination of #{format_current_valid_taxon}"
        elsif original_combination?
          "see #{format_current_valid_taxon}"
        elsif unavailable_misspelling?
          "a misspelling of #{format_current_valid_taxon}"
        elsif unavailable_uncategorized?
          "see #{format_current_valid_taxon}"
        elsif invalid?
          taxon.status
        else
          "valid"
        end
      end

      def format_senior_synonym
        current_valid_taxon_including_synonyms.decorate.link_to_taxon_with_author_citation
      end

      def format_current_valid_taxon
        current_valid_taxon.decorate.link_to_taxon_with_author_citation
      end
  end
end
