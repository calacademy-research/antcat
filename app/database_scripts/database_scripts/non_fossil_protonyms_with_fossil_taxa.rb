module DatabaseScripts
  class NonFossilProtonymsWithFossilTaxa < DatabaseScript
    def results
      Protonym.extant.joins(:taxa).where(taxa: { fossil: true }).includes(:taxa)
    end

    def render
      as_table do |t|
        t.header :protonym, :taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            taxa_list(protonym.taxa)
          ]
        end
      end
    end
  end
end

__END__

title: Non-fossil protonyms with fossil taxa
category: Protonyms

issue_description: This protonym is not fossil, but one of its taxa is.

description: >
  This is not necessarily incorrect.


  This script is the reverse of %dbscript:FossilTaxaWithNonFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
