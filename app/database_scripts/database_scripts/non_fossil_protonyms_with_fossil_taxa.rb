# frozen_string_literal: true

module DatabaseScripts
  class NonFossilProtonymsWithFossilTaxa < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_REVERSED
    end

    def results
      Protonym.extant.joins(:taxa).where(taxa: { fossil: true }).includes(:taxa)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Taxa', 'Locality'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            taxon_links(protonym.taxa),
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
tags: [protonyms, regression-test]

issue_description: This protonym is not fossil, but one of its taxa is.

description: >
  This script is the reverse of %dbscript:FossilTaxaWithNonFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon
