# frozen_string_literal: true

module DatabaseScripts
  class JuniorSynonymOfHistoryItemsMissing < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Taxon.species_group_names.synonyms.
        joins(<<~SQL.squish).where("history_items.id IS NULL").limit(LIMIT)
          JOIN taxa current_taxons_taxa ON current_taxons_taxa.id = taxa.current_taxon_id
          LEFT OUTER JOIN protonyms ON protonyms.id = taxa.protonym_id
          LEFT OUTER JOIN history_items ON history_items.protonym_id = protonyms.id AND
            (
              history_items.type = 'JuniorSynonymOf'
              AND
              current_taxons_taxa.protonym_id = history_items.object_protonym_id
            )
        SQL
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym', 'Missing fact'
        t.rows do |taxon|
          missing_fact = <<~STR
            Missing JuniorSynonymOf item with object_protonym_id=#{taxon.current_taxon.protonym_id}<br><br>
            or incorrect taxa.current_taxon_id
          STR

          [
            taxon_link(taxon),
            taxon.status,
            protonym_link(taxon.protonym),
            missing_fact
          ]
        end
      end
    end
  end
end

__END__

title: >
  'Junior synonym of' history items (missing)

# TODO: Change to: section: disagreeing-history
section: research
category: History
tags: [new!, list]

description: >
  This script can be ignored until we have migrated history items to relational items.


  Only species-group names.

related_scripts:
  - JuniorSynonymOfHistoryItemsMissing
