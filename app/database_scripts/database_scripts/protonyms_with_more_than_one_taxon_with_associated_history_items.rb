module DatabaseScripts
  class ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa)
    end

    def results
      Protonym.distinct.joins(:taxa).
        where(taxa: { id: Taxon.joins(:history_items).select(:id) }).
        group("protonyms.id").having("COUNT(protonyms.id) > 1")
    end

    def render
      as_table do |t|
        t.header :protonym, :ranks_of_taxa, :taxa, :statuses_of_taxa, :looks_like_a_false_positive?
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.taxa.distinct.pluck(:type).join(', '),
            protonym.taxa.map(&:link_to_taxon).join('<br>'),
            protonym.taxa.map(&:status).join('<br>'),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : '<span class="bold-warning">No</span>')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms

issue_description: More than one of this protonym's taxa have history items.

description: >
  Go to the protonym's page to see all history items in one place.

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon
