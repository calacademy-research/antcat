# frozen_string_literal: true

module Protonyms
  class ReorderHistoryItemsController < ApplicationController
    before_action :ensure_user_is_editor

    def show
      @protonym = find_protonym
    end

    def create
      @protonym = find_protonym

      if Protonyms::Operations::ReorderHistoryItems[@protonym, new_order]
        @protonym.create_activity Activity::REORDER_HISTORY_ITEMS, current_user
        redirect_to protonym_reorder_history_items_path(@protonym), notice: 'History items were successfully reordered.'
      else
        flash.now[:alert] = @protonym.errors.full_messages.to_sentence
        render :show, status: :unprocessable_content
      end
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end

      def new_order
        # The form sends `new_order=""` when there is nothing to reorder; `expect` would reject that with 400.
        params[:new_order].to_s.split(',') # rubocop:disable Rails/StrongParametersExpect
      end
  end
end
