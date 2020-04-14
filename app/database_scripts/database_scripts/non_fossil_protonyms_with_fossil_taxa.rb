# frozen_string_literal: true

module DatabaseScripts
  class NonFossilProtonymsWithFossilTaxa < DatabaseScript
    def results
      Protonym.extant.joins(:taxa).where(taxa: { fossil: true }).includes(:taxa)
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

title: Non-fossil protonyms with fossil taxa

section: reversed
category: Protonyms
tags: [regression-test]

issue_description: This protonym is not fossil, but one of its taxa is.

description: >
  Can be fixed by script if all taxa/protonyms should be changed in the same way.


  This script is the reverse of %dbscript:FossilTaxaWithNonFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
