# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNamesUsedForMoreThanOneTaxon < DatabaseScript
    RHYTIDOPONERA_CLARKI_ID = 447315

    def self.looks_like_a_false_positive? taxon
      taxon.homonym_replaced_by_id == RHYTIDOPONERA_CLARKI_ID
    end

    def results
      Taxon.where(
        homonym_replaced_by_id: Taxon.group(:homonym_replaced_by_id).having('COUNT(id) > 1').select(:homonym_replaced_by_id)
      )
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'replaced_by', 'Status of replaced_by', 'Looks like a false positive?'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(taxon.homonym_replaced_by),
            taxon.homonym_replaced_by.status,
            (self.class.looks_like_a_false_positive?(taxon) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description: This taxon has a replacement name that is also the replacement name of another taxon.

description: >
  %taxon447315 can be ignored. It is a very case where a replacement name was applied twice.
