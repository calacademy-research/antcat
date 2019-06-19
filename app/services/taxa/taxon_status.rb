module Taxa
  class TaxonStatus
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      parts = []
      parts << "<i>incertae sedis</i> in #{incertae_sedis_in}" if incertae_sedis_in
      parts << "<i>nomen nudum</i>" if nomen_nudum?
      parts << "unresolved junior homonym" if unresolved_homonym?
      parts << main_status
      parts << 'ichnotaxon' if ichnotaxon?
      parts.join(', ').html_safe
    end

    private

      attr_reader :taxon

      delegate :status, :incertae_sedis_in, :homonym_replaced_by, :unresolved_homonym?, :ichnotaxon?,
        :current_valid_taxon, :nomen_nudum?, to: :taxon

      def main_status
        return "homonym replaced by #{link_homonym_replaced_by}" if homonym_replaced_by

        case status
        when Status::SYNONYM                   then "junior synonym of current valid taxon #{link_current_valid_taxon}"
        when Status::OBSOLETE_COMBINATION      then "an obsolete combination of #{link_current_valid_taxon}"
        when Status::ORIGINAL_COMBINATION      then "see #{link_current_valid_taxon}"
        when Status::UNAVAILABLE_MISSPELLING   then "a misspelling of #{link_current_valid_taxon}"
        when Status::UNAVAILABLE_UNCATEGORIZED then "see #{link_current_valid_taxon}"
        else                                        status
        end
      end

      def link_homonym_replaced_by
        homonym_replaced_by.decorate.link_to_taxon_with_author_citation
      end

      def link_current_valid_taxon
        current_valid_taxon.decorate.link_to_taxon_with_author_citation
      end
  end
end
