# frozen_string_literal: true

# NOTE: Copy-pasted into `Taxa::ReorderReferenceSectionsController`.

module Taxa
  class ReorderHistoryItemsController < ApplicationController
    before_action :ensure_user_is_editor

    def create
      taxon = find_taxon

      # NOTE: "taxon_history_item_ids" would be better, but `params[:taxon_history_item]` is what jQuery sends it as.
      if Taxa::Operations::ReorderHistoryItems[taxon, params[:taxon_history_item]]
        taxon.create_activity :reorder_taxon_history_items, current_user
        render json: { success: true }
      else
        render json: taxon.errors, status: :unprocessable_entity
      end
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end
  end
end
