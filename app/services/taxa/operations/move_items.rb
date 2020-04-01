# frozen_string_literal: true

module Taxa
  module Operations
    class MoveItems
      include Service

      attr_private_initialize :to_taxon, :history_items

      def call
        move_history_items!
      end

      private

        def move_history_items!
          history_items.each do |history_item|
            history_item.taxon = to_taxon
            history_item.save!
          end
        end
    end
  end
end
