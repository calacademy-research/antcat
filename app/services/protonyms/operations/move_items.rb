# frozen_string_literal: true

module Protonyms
  module Operations
    class MoveItems
      include Service

      attr_private_initialize :to_protonym, [history_items: []]

      def call
        move_history_items!
      end

      private

        def move_history_items!
          history_items.each do |history_item|
            history_item.reload # Reload to make sure positions are updated correctly.

            history_item.protonym = to_protonym
            history_item.save!
          end
        end
    end
  end
end
