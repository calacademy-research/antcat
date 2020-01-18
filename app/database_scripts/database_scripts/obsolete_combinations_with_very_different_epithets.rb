module DatabaseScripts
  class ObsoleteCombinationsWithVeryDifferentEpithets < DatabaseScript
    def results
      Species.obsolete_combinations.joins(:name, current_valid_taxon: :name).
        where(current_valid_taxons_taxa: { type: 'Species' }).
        where("SUBSTR(names_taxa.epithet, 1, 3) != SUBSTR(names.epithet, 1, 3)").
        includes(:name, current_valid_taxon: :name)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :origin, :current_valid_taxon,
          :current_valid_taxon_status, :taxon_epithet, :current_valid_taxon_epithet,
          :taxon_or_protonym_taxon_in_synonyms_list?

        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            origin_warning(taxon),
            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            taxon.name.epithet,
            current_valid_taxon.name.epithet,

            ('Yes' if taxon.current_valid_taxon.synonyms_history_items_containing_taxons_protonyms_taxa(taxon).present?)
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [slow-render]

issue_description: This obsolete combination has a very different epithet compared to its `current_valid_taxon`.

description: >
  "Yes" in the "Taxon or protonym taxon in synonyms list?" means that the status should probably be changed to 'synonym'.
  More specifically it means that either the taxon itself (left-most column) or a taxon record belonging to its
  protonym appears in a "synonyms history item" owned by the current valid taxon. Open the taxon in the catalog to
  see the history item. If this is the case, then these could be fixed by script.


  "Very different" means that the first three letters in the epithet are not the same.


  Only species with a `current_valid_taxon` that is also a species are checked.


  These obsolete combinations should probably have the status 'synonym'.


  Records in this script also often appears in %dbscript:ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
