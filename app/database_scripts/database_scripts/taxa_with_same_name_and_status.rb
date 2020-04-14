# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithSameNameAndStatus < DatabaseScript
    def results
      name_and_status = Taxon.joins(:name).group('names.name, status').having('COUNT(*) > 1')

      Taxon.joins(:name).
        where(names: { name: name_and_status.select(:name) }, status: name_and_status.select(:status)).
        order('names.name').
        includes(protonym: { authorship: :reference })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Authorship', 'Status', 'Unresolved homonym?'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.authorship_reference.keey,
            taxon.status,
            ('Yes' if taxon.unresolved_homonym?)
          ]
        end
      end
    end
  end
end

__END__

section: list
category: Catalog
tags: []

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart
