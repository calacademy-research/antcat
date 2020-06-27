# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithVeryDifferentEpithets < DatabaseScript
    def results
      Species.obsolete_combinations.joins(:name, current_taxon: :name).
        where(current_taxons_taxa: { type: Rank::SPECIES }).
        where("SUBSTR(names_taxa.epithet, 1, 3) != SUBSTR(names.epithet, 1, 3)").
        includes(:name, current_taxon: :name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'Origin', 'current_taxon',
          'current_taxon status', 'Taxon epithet', 'current_taxon epithet',
          'Probably change CT?',
          'Probably change status to synonym?'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon
          ct_cleanup_taxon = Taxa::CleanupTaxon.new(current_taxon)

          [
            taxon_link(taxon),
            taxon.rank,
            taxon.status,
            origin_warning(taxon),
            taxon_link(current_taxon),
            current_taxon.status,
            taxon.name.epithet,
            current_taxon.name.epithet,

            ('Yes' if ct_cleanup_taxon.synonyms_history_items_containing_taxons_protonyms_taxa_except_self(taxon).present?),
            ('Yes' if ct_cleanup_taxon.synonyms_history_items_containing_taxon(taxon).present?)
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Catalog
tags: [slow-render]

issue_description: This obsolete combination has a very different epithet compared to its `current_taxon`.

description: >
  "Yes" in the "Taxon or protonym taxon in synonyms list?" means that the status should probably be changed to 'synonym'.
  More specifically it means that either the taxon itself (left-most column) or a taxon record belonging to its
  protonym appears in a "synonyms history item" owned by the current taxon. Open the taxon in the catalog to
  see the history item. If this is the case, then these could be fixed by script.


  "Very different" means that the first three letters in the epithet are not the same.


  Only species with a `current_taxon` that is also a species are checked.


  These obsolete combinations should probably have the status 'synonym'.


  Records in this script also often appears in %dbscript:ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
