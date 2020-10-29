# frozen_string_literal: true

# TODO: Copy-pasted into `Taxa::Operations::ReorderReferenceSections`.

module Protonyms
  module Operations
    class ReorderHistoryItems
      include Service

      attr_private_initialize :protonym, :reordered_ids

      def call
        reorder_history_items reordered_ids
      end

      private

        delegate :protonym_history_items, :errors, to: :protonym, private: true

        def reorder_history_items reordered_ids
          return false unless reordered_ids_valid? reordered_ids

          protonym.transaction do
            reordered_ids.each_with_index do |id, index|
              history_item = HistoryItem.find(id)
              history_item.update!(position: (index + 1))
            end
          end

          true
        rescue ActiveRecord::RecordInvalid
          errors.add :protonym_history_items, "History items are not valid, please fix them first"
          false
        end

        def reordered_ids_valid? reordered_ids_strings
          current_ids = protonym_history_items.pluck :id
          reordered_ids = reordered_ids_strings.map(&:to_i)

          if current_ids == reordered_ids
            errors.add :protonym_history_items, "History items are already ordered like this"
          end

          unless current_ids.sort == reordered_ids.sort
            errors.add :protonym_history_items, <<-ERROR.squish
              Reordered IDs '#{reordered_ids}' doesn't match current IDs #{current_ids}.
            ERROR
          end

          errors.empty?
        end
    end
  end
end
