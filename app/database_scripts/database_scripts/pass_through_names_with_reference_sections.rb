# frozen_string_literal: true

module DatabaseScripts
  class PassThroughNamesWithReferenceSections < DatabaseScript
    def results
      TaxonQuery.new.pass_through_names.left_outer_joins(:reference_sections).
        distinct.where("reference_sections.id IS NOT NULL")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.type,
            taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Pass-through names with reference sections

section: regression-test
category: Catalog
tags: []

issue_description: This taxon is a "pass-through name", but is has a reference section.

description: >
  Obsolete combination and unavailable misspellings with reference sections.
