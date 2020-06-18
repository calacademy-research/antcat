# frozen_string_literal: true

module DatabaseScripts
  class FossilProtonymsWithNonFossilTaxa < DatabaseScript
    def results
      Protonym.fossil.joins(:taxa).where(taxa: { fossil: false }).includes(:taxa)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Taxa', 'Locality'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            taxa_list(protonym.taxa),
            protonym.locality
          ]
        end
      end
    end
  end
end

__END__

title: Fossil protonyms with non-fossil taxa

section: reversed
category: Protonyms
tags: [regression-test]

issue_description: This protonym is fossil, but one of its taxa is extant.

description: >
  Can be fixed by script if all taxa/protonyms should be changed in the same way.


  This script is the reverse of %dbscript:NonFossilTaxaWithFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon
