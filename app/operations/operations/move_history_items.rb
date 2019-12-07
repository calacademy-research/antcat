module Operations
  class MoveHistoryItems
    include Operation

    def initialize to_taxon:, history_items:
      @to_taxon = to_taxon
      @history_items = history_items
    end

    def self.description to_taxon:, history_items:
      history_items_description = history_items.map do |history_item|
        "  * From #{history_item.taxon.link_to_taxon}: #{Detax[history_item.taxt]}"
      end.join("\n")

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

    private

      attr_reader :to_taxon, :history_items
  end
end
