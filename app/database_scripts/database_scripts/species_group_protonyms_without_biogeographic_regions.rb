# frozen_string_literal: true

# TODO: Add validations once script has been cleared.
module DatabaseScripts
  class SpeciesGroupProtonymsWithoutBiogeographicRegions < DatabaseScript
    LIMIT = 5000

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
        t.header 'Protonym', 'Authorship', 'Locality', 'Suggested bio region'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.locality,
            country_mappings[protonym.locality]
          ]
        end
      end
    end

    private

      def country_mappings
        @_country_mappings ||= Protonym.where.not(biogeographic_region: nil).
          where.not(locality: nil).pluck(:locality, :biogeographic_region).to_h
      end
  end
end

__END__

title: Species-group protonyms without biogeographic regions

section: main
category: Protonyms
tags: [new!, slow-render]

issue_description: This [non-fossil] species-group name protonym has no biogeographic region.

description: >
  Not handled: Protonym that (should) share types.

related_scripts:
  - SpeciesGroupProtonymsWithoutBiogeographicRegions
