# frozen_string_literal: true

module DatabaseScripts
  class UnjustifiedEmendationHistoryItemsNotMatchingTheirRecord < DatabaseScript
    # The checks of `HistoryItem#validate_emendation_object_taxon`, which run only when the item is saved. A later
    # change to the linked record (its status, or its current taxon moved to another name) is caught here. The
    # spellings are compared byte for byte: the tables' collation ignores case and accents, and a spelling that
    # differs only by those is what this script is for (review of #1620).
    MISMATCH_SQL = <<~SQL.squish
      records.id IS NULL
      OR records.status <> :status
      OR record_current_taxa.protonym_id IS NULL
      OR record_current_taxa.protonym_id <> history_items.protonym_id
      OR CAST(COALESCE(record_names.epithet, '') AS BINARY) <>
        CAST(COALESCE(TRIM(REPLACE(REPLACE(history_items.text_value, '<i>', ''), '</i>', '')), '') AS BINARY)
    SQL

    def results
      HistoryItem.
        where(type: History::Definitions::EMENDATION, subtype: History::Definitions::EMENDATION_UNJUSTIFIED).
        joins('LEFT JOIN taxa records ON records.id = history_items.object_taxon_id').
        joins('LEFT JOIN names record_names ON record_names.id = records.name_id').
        joins('LEFT JOIN taxa record_current_taxa ON record_current_taxa.id = records.current_taxon_id').
        where(MISMATCH_SQL, status: Status::UNJUSTIFIED_EMENDATION).
        preload(:protonym, object_taxon: [:name, { current_taxon: :protonym }])
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Linked record', 'Problem'
        t.rows do |history_item|
          record = history_item.object_taxon
          [
            history_item_link_and_taxt(history_item),
            protonym_link(history_item.protonym),
            (record ? taxon_link(record) : '(none)'),
            problems(history_item, record)
          ]
        end
      end
    end

    private

      def problems history_item, record
        return 'no linked record' unless record

        found = []
        found << "the record's status is #{record.status}" unless record.unjustified_emendation?
        unless record.current_taxon&.protonym_id == history_item.protonym_id
          found << "the record's current taxon has another protonym"
        end
        if history_item.text_value.to_s.gsub(%r{</?i>}, '').strip != record.name.epithet
          found << "the spelling differs from the record's (#{record.name.epithet})"
        end
        # SQL trims spaces only; Ruby also strips tabs and line breaks (review of #1620).
        found.empty? ? 'the spelling differs from the record\'s in white space' : found.join('; ')
      end
  end
end

__END__

title: Unjustified emendation history items not matching their record

section: regression-test
tags: [rel-hist, protonyms, new!]

description: >
  "Unjustified emendation of spelling to ..." history items whose linked record no longer qualifies: it is not
  an unjustified emendation any more, its current taxon is a name of another protonym, or the emended spelling
  in the item is not the record's epithet. The item checks these only when it is saved, so a later change to the
  record shows up here.


  Fix the record, or edit the history item to link the right one.
