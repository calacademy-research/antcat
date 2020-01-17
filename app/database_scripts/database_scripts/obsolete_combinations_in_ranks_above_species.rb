module DatabaseScripts
  class ObsoleteCombinationsInRanksAboveSpecies < DatabaseScript
    def results
      Taxon.obsolete_combinations.where(type: Taxon::TYPES_ABOVE_SPECIES).includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :rank, :current_valid_taxon, :current_valid_taxon_status, :current_valid_taxon_rank
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.type,

            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            current_valid_taxon.type
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [list]

description: >
  This is not an issue. Script was added to investigate obsolete combinations and how to move `type_taxon` to the protonym.
