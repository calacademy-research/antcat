module DatabaseScripts
  class ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon < DatabaseScript
    def results
      Protonym.joins(:taxa).
        where.not(taxa: { status: Status::OBSOLETE_COMBINATION }).
        group('protonyms.id').having("COUNT(DISTINCT taxa.current_valid_taxon_id) > 1")
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa, :statuses_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

description: >
  Obsolete combinations are excluded.

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon
