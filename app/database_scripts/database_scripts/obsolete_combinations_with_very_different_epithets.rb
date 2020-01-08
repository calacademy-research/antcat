module DatabaseScripts
  class ObsoleteCombinationsWithVeryDifferentEpithets < DatabaseScript
    def results
      Species.obsolete_combinations.joins(:name, current_valid_taxon: :name).
        where(current_valid_taxons_taxa: { type: 'Species' }).
        where("SUBSTR(names_taxa.epithet, 1, 3) != SUBSTR(names.epithet, 1, 3)")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :current_valid_taxon_status, :taxon_epithet, :current_valid_taxon_epithet
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            taxon.name.epithet,
            current_valid_taxon.name.epithet
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: This obsolete combination has a very different epithet compared to its `current_valid_taxon`.

description: >
  "Very different" means that the first three letters in the epithet are not the same.


  Only species with a `current_valid_taxon` that is also a species are checked.


  These obsolete combinations should probably have the status 'synonym'.

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
