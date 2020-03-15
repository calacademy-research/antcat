module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxonOrSynonym < DatabaseScript
    def results
      Protonym.joins(:taxa).
        where(taxa: { status: [Status::VALID, Status::SYNONYM] }).
        group(:protonym_id).having('COUNT(protonym_id) > 1').
        where.not(id: covered_in_related_scripts)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
          ]
        end
      end
    end

    private

      def covered_in_related_scripts
        DatabaseScripts::ProtonymsWithMoreThanOneValidTaxon.new.results.select(:id) +
          DatabaseScripts::ProtonymsWithMoreThanOneSynonym.new.results.select(:id)
      end
  end
end

__END__

category: Protonyms
tags: []

description: >
  Matches already appearing in these two scripts are excluded:


  * %dbscript:ProtonymsWithMoreThanOneSynonym

  * %dbscript:ProtonymsWithMoreThanOneValidTaxonOrSynonym

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon

  - TypeTaxaAssignedToMoreThanOneTaxon
