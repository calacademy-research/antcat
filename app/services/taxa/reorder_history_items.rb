module Taxa
  class ReorderHistoryItems
    include Service

    def initialize taxon, reordered_ids
      @taxon = taxon
      @reordered_ids = reordered_ids
    end

    def call
      reorder_history_items reordered_ids
    end

    private

      attr_reader :taxon, :reordered_ids

      delegate :history_items, :create_activity, :errors, to: :taxon

      def reorder_history_items reordered_ids
        return unless reordered_ids_valid? reordered_ids

        previous_ids = history_items.pluck :id

        reordered_ids.each_with_index do |id, index|
          item = TaxonHistoryItem.find(id)
          item.update(position: (index + 1))
        end

        create_activity :reorder_taxon_history_items,
          parameters: { previous_ids: previous_ids, reordered_ids: history_items.pluck(:id) }

        true
      end

      def reordered_ids_valid? reordered_ids_strings
        current_ids = history_items.pluck :id
        reordered_ids = reordered_ids_strings.map(&:to_i)

        if current_ids == reordered_ids
          errors.add :history_items, "History items are already ordered like this"
        end

        unless current_ids.sort == reordered_ids.sort
          errors.add :history_items, <<-ERROR.squish
            Reordered IDs '#{reordered_ids}' doesn't match current IDs #{current_ids}.
          ERROR
        end

        errors.empty?
      end
  end
end
