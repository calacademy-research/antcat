# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTaxaWithVeryDifferentEpithets < DatabaseScript
    FALSE_POSITIVES_PROTONYM_IDS = [
      157656 # "ager agra"
    ]

    def results
      Protonym.joins(taxa: :name).
        where(taxa: { type: Rank::SPECIES_GROUP_NAMES }).
        where.not(taxa: { status: Status::UNAVAILABLE_MISSPELLING }).
        where.not(id: FALSE_POSITIVES_PROTONYM_IDS).
        group('protonyms.id').having("COUNT(DISTINCT SUBSTR(names.epithet, 1, 3)) > 1").distinct.
        includes(:name)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Epithets of taxa', 'Ranks of taxa', 'Statuses of taxa', 'Taxa'

        t.rows do |protonym|
          epithets = protonym.taxa.joins(:name).distinct.pluck(:epithet)

          [
            protonym.decorate.link_to_protonym,
            epithets.join(', '),
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            taxon_links(protonym.taxa)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Protonyms
tags: []

issue_description: The taxa of this protonym have very different epithets.

description: >
  "Very different" means that the first three letters in the epithet are not the same.


  Only species-group names are checked.

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
