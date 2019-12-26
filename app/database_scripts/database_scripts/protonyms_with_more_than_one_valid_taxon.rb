module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxon < DatabaseScript
    def results
      Protonym.joins(:taxa).where(taxa: { status: Status::VALID }).group(:protonym_id).having('COUNT(protonym_id) > 1')
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.pluck(:type).join(', ')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: [regression-test]

description: >
   It is fine for a protonym to have more than one valid taxa if it is above the rank of
   genus (one valid taxa in rank: tribe, subfamily or family).

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon
