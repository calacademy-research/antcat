# frozen_string_literal: true

# `CompactStatus` was added as an alternative to this class. They may or may not be merged in the future.

module Taxa
  class ExpandedStatus
    include Service

    SELF_STATUSES = [
      Status::VALID,
      Status::UNIDENTIFIABLE,
      Status::UNAVAILABLE,
      Status::EXCLUDED_FROM_FORMICIDAE
    ]

    attr_private_initialize :taxon

    def call
      parts = []
      parts << "<i>incertae sedis</i> in #{incertae_sedis_in.downcase}" if incertae_sedis_in
      parts << "<i>nomen nudum</i>" if nomen_nudum?
      parts << "unresolved junior homonym" if unresolved_homonym?
      parts << "collective group name" if collective_group_name?
      parts << main_status
      parts << 'ichnotaxon' if ichnotaxon?
      parts.join(', ').html_safe
    end

    private

      delegate :status, :protonym, :incertae_sedis_in, :homonym_replaced_by, :unresolved_homonym?, :ichnotaxon?,
        :current_taxon, :collective_group_name?, to: :taxon, private: true
      delegate :ichnotaxon?, :nomen_nudum?, to: :protonym, private: true

      def main_status
        case status
        when Status::SYNONYM                 then "junior synonym of current valid taxon #{link_current_taxon}"
        when Status::HOMONYM                 then "homonym replaced by #{link_homonym_replaced_by}"
        when Status::OBSOLETE_COMBINATION    then "an obsolete #{name_of_obsoletes} of #{link_current_taxon}"
        when Status::UNAVAILABLE_MISSPELLING then "a misspelling of #{link_current_taxon}"
        when *SELF_STATUSES                  then status
        else                                 raise "unknown status: #{status}"
        end
      end

      def name_of_obsoletes
        taxon.decorate.name_of_obsoletes
      end

      def link_homonym_replaced_by
        homonym_replaced_by.decorate.link_to_taxon_with_author_citation
      end

      def link_current_taxon
        current_taxon.decorate.link_to_taxon_with_author_citation
      end
  end
end
