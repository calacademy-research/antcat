module Taxa
  class ReorderHistoryItemsController < ApplicationController
    before_action :ensure_can_edit_catalog
    before_action :set_taxon

    def create
      if Taxa::ReorderHistoryItems[@taxon, params[:taxon_history_item]]
        render json: { success: true }
      else
        render json: @taxon.errors, status: :unprocessable_entity
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end
  end
end
