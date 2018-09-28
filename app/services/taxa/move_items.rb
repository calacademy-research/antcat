module Taxa
  class MoveItems
    include Service

    def initialize to_taxon, history_items
      @to_taxon = to_taxon
      @history_items = history_items
    end

    def call
      move_history_items!
    end

    private

      attr_reader :to_taxon, :history_items

      def move_history_items!
        history_items.each do |history_item|
          history_item.taxon = to_taxon
          history_item.save!
        end
      end
  end
end
