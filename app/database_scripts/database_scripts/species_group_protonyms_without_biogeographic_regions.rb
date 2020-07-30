# frozen_string_literal: true

# TODO: Add validations once script has been cleared.
module DatabaseScripts
  class SpeciesGroupProtonymsWithoutBiogeographicRegions < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Protonym.joins(:name).
        where(names: { type: Name::SPECIES_GROUP_NAMES }).
        where(biogeographic_region: nil).
        where(fossil: false).
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation
          ]
        end
      end
    end
  end
end

__END__

title: Species-group protonyms without biogeographic regions

section: main
category: Protonyms
tags: [new!]

issue_description: This [non-fossil] species-group name protonym has no biogeographic region.

description: >

related_scripts:
  - SpeciesGroupProtonymsWithoutBiogeographicRegions
