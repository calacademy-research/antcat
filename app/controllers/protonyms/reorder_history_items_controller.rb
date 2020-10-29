# frozen_string_literal: true

module Protonyms
  class ReorderHistoryItemsController < ApplicationController
    before_action :ensure_user_is_editor

    def create
      protonym = find_protonym

      # NOTE: "history_item_ids" would be better, but `params[:history_item]` is what jQuery sends it as.
      if Protonyms::Operations::ReorderHistoryItems[protonym, params[:history_item]]
        protonym.create_activity :reorder_protonym_history_items, current_user
        render json: { success: true }
      else
        render json: protonym.errors, status: :unprocessable_entity
      end
    end

    private

      def find_protonym
        Protonym.find(params[:protonym_id])
      end
  end
end
