# frozen_string_literal: true

module DatabaseScripts
  class NonStandardReplacementNameHistoryItems < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::FALSE_POSITIVES
    end

    def results
      HistoryItem.taxts_only.
        where("history_items.taxt LIKE 'Replacement name:%'").
        where.not("taxt REGEXP ?", "^Replacement name: {#{Taxt::TAXAC_TAG} [0-9]+}\.?$")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Terminal taxon', 'taxt', 'Standard-ish?'
        t.rows do |history_item|
          taxt = history_item.taxt

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxon_link(history_item.terminal_taxon),
            taxt,
            (history_item.standard_format? ? 'Yes' : 'No')
          ]
        end
      end
    end
  end
end

__END__

title: Non-standard 'Replacement name:' history items

section: research
tags: [replacement-names, taxt-hist]

issue_description:

description: >
  This does not mean that they are incorrect, because we want to support these cases:


  * Replacement name: {taxac 441598} ({ref 132776}: 221).

  * Replacement name: {taxac 507625} (replacement name for {taxac 446502}).

related_scripts:
  - NonStandardReplacementNameHistoryItems
