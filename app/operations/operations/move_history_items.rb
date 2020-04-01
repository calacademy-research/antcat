# frozen_string_literal: true

module Operations
  class MoveHistoryItems
    include Operation

    attr_private_initialize [:to_taxon, :history_items]

    def self.description to_taxon:, history_items:
      history_items_description = history_items.map do |history_item|
        "  * From #{history_item.taxon.link_to_taxon}: #{Detax[history_item.taxt]}"
      end.join("\n").presence || "  * No history items"

      <<~TEXT
        * Move history items to #{to_taxon}
        #{history_items_description}
      TEXT
    end

    def execute
      history_items.each do |history_item|
        fail! "Could not update history item ##{history_item.id}" unless history_item.update(taxon: to_taxon)
      end
    end
  end
end
