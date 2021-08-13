# frozen_string_literal: true

# TODO: Add validations once script has been cleared.
module DatabaseScripts
  class SpeciesGroupProtonymsWithoutBioregions < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::FALSE_POSITIVES
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.except(:select).count}
      STR
    end

    def results
      Protonym.extant.species_group_names.where(bioregion: nil).
        select(<<~SQL.squish)
          protonyms.*, (
            SELECT hi.type FROM history_items hi
            WHERE hi.protonym_id = protonyms.id
            AND hi.type = "ReplacementNameFor" LIMIT 1
          ) AS has_replacement_name_for_history_item
        SQL
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Locality', 'Suggested bioregion', 'Terminal taxon',
          'TT status', 'ReplacementNameFor HI?'
        t.rows do |protonym|
          locality = protonym.locality
          terminal_taxon = protonym.terminal_taxon

          [
            protonym.decorate.link_to_protonym,
            locality,
            (country_mappings[locality] if locality),
            taxon_link(terminal_taxon),
            terminal_taxon&.status,
            protonym.has_replacement_name_for_history_item
          ]
        end
      end
    end

    private

      def country_mappings
        @_country_mappings ||= Protonym.where.not(bioregion: nil).
          where.not(locality: nil).pluck(:locality, :bioregion).to_h
      end
  end
end

__END__

title: Species-group protonyms without bioregions

section: research
tags: [protonyms, slow-render]

issue_description: This [non-fossil] species-group name protonym has no bioregion.

description: >
  **ReplacementNameFor HI?** = may be a new replacement name which should inherit types (and bioregion).

related_scripts:
  - SpeciesGroupProtonymsWithoutBioregions
