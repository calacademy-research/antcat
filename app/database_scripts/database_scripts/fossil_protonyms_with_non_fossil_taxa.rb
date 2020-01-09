module DatabaseScripts
  class FossilProtonymsWithNonFossilTaxa < DatabaseScript
    def results
      Protonym.fossil.joins(:taxa).where(taxa: { fossil: false }).includes(:taxa)
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

title: Fossil protonyms with non-fossil taxa
category: Protonyms
tags: []

issue_description: This protonym is fossil, but one of its taxa is extant.

description: >
  This is not necessarily incorrect.


  This script is the reverse of %dbscript:NonFossilTaxaWithFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
