# frozen_string_literal: true

# This class was added as an alternative to `ExpandedStatus. The classes may or may not be merged in the future.
#
# Differences:
# * The compact status does not include "valid".
# * The compact status does not include articles ("a" / "an").
# * The compact status is less detailed (no "ichnotaxon" for example).
# * The compact status does not include author citations.

module Taxa
  class CompactStatus
    include Service

    SELF_STATUSES = [
      Status::UNIDENTIFIABLE,
      Status::UNAVAILABLE,
      Status::EXCLUDED_FROM_FORMICIDAE
    ]

    attr_private_initialize :taxon

    def call
      parts = []
      parts << "<i>nomen nudum</i>" if nomen_nudum?
      parts << "unresolved junior homonym" if unresolved_homonym?
      parts << main_status unless nomen_nudum?
      parts.compact.join(', ').html_safe
    end

    private

      delegate :status, :homonym_replaced_by, :unresolved_homonym?, :current_taxon,
        :nomen_nudum?, to: :taxon, private: true

      def main_status
        case status
        when Status::VALID                     then nil
        when Status::SYNONYM                   then "junior synonym of #{link_current_taxon}"
        when Status::HOMONYM                   then "homonym replaced by #{link_homonym_replaced_by}"
        when Status::OBSOLETE_COMBINATION      then "obsolete combination of #{link_current_taxon}"
        when Status::UNAVAILABLE_MISSPELLING   then "misspelling of #{link_current_taxon}"
        when Status::UNAVAILABLE_UNCATEGORIZED then "see #{link_current_taxon}"
        when *SELF_STATUSES                    then status
        else                                   raise "unknown status: #{status}"
        end
      end

      def link_homonym_replaced_by
        CatalogFormatter.link_to_taxon(homonym_replaced_by)
      end

      def link_current_taxon
        CatalogFormatter.link_to_taxon(current_taxon)
      end
  end
end
