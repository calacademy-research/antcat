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

    def initialize taxon
      @taxon = taxon
    end

    def call
      parts = []
      parts << "<i>nomen nudum</i>" if nomen_nudum?
      parts << "unresolved junior homonym" if unresolved_homonym?
      parts << main_status unless nomen_nudum?
      parts.compact.join(', ').html_safe
    end

    private

      attr_reader :taxon

      delegate :status, :homonym_replaced_by, :unresolved_homonym?, :current_valid_taxon, :nomen_nudum?, to: :taxon

      def main_status
        case status
        when Status::VALID                     then nil
        when Status::SYNONYM                   then "junior synonym of #{link_current_valid_taxon}"
        when Status::HOMONYM                   then "homonym replaced by #{link_homonym_replaced_by}"
        when Status::OBSOLETE_COMBINATION      then "obsolete combination of #{link_current_valid_taxon}"
        when Status::UNAVAILABLE_MISSPELLING   then "misspelling of #{link_current_valid_taxon}"
        when Status::UNAVAILABLE_UNCATEGORIZED then "see #{link_current_valid_taxon}"
        when *SELF_STATUSES                    then status
        else                                   raise "unknown status: #{status}"
        end
      end

      def link_homonym_replaced_by
        homonym_replaced_by.link_to_taxon
      end

      def link_current_valid_taxon
        current_valid_taxon.link_to_taxon
      end
  end
end
