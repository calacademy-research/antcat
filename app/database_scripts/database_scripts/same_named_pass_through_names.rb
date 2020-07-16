# frozen_string_literal: true

module DatabaseScripts
  class SameNamedPassThroughNames < DatabaseScript
    def results
      TaxonQuery.new.pass_through_names.
        joins(:current_taxon).
        where("current_taxons_taxa.name_cache = taxa.name_cache").
        includes(
          :name,
          current_taxon: [:name, protonym: [:name, { authorship: :reference }]],
          protonym: [:name, { authorship: :reference }]
        )
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Author citation', 'Status', 'current_taxon', 'Author citation', 'Status'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.author_citation,
            taxon.status,
            taxon_link(taxon),
            current_taxon.author_citation,
            current_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Same-named pass-through names

section: regression-test
category: Catalog
tags: []

description: >
  See %github283

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
