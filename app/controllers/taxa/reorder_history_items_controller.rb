module Taxa
  class ReorderHistoryItemsController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon

    def create
      previous_ids = @taxon.history_items.pluck(:id)

      if Taxa::Operations::ReorderHistoryItems[@taxon, params[:taxon_history_item]]
        create_activity previous_ids
        render json: { success: true }
      else
        render json: @taxon.errors, status: :unprocessable_entity
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def create_activity previous_ids
        @taxon.create_activity :reorder_taxon_history_items,
          parameters: { previous_ids: previous_ids, reordered_ids: @taxon.history_items.pluck(:id) }
      end
  end
end
