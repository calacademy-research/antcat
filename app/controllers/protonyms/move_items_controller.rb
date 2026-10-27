# frozen_string_literal: true

# TODO: Disabled because `new` is step 1 and `show` step 2.
# rubocop:disable-next Rails/ActionOrder
module Protonyms
  class MoveItemsController < ApplicationController
    before_action :ensure_user_is_editor

    def new
      @protonym = find_protonym
    end

    def show
      @protonym = find_protonym
      @to_protonym = find_to_protonym

      unless @to_protonym
        redirect_to({ action: :new }, alert: "Target must be specified.")
      end
    end

    def create
      @protonym = find_protonym
      @to_protonym = find_to_protonym

      if @to_protonym.nil? || @to_protonym == @protonym
        redirect_to({ action: :new }, alert: "Target must be specified, and must not be the same protonym.")
        return
      end

      if history_items.empty?
        flash.now[:alert] = "At least one item must be selected."
        render :show, status: :unprocessable_content
        return
      end

      if Protonyms::Operations::MoveItems[@to_protonym, history_items: history_items]
        @protonym.create_activity Activity::MOVE_PROTONYM_ITEMS, current_user,
          parameters: { to_protonym_id: @to_protonym.id }
        redirect_to protonym_move_items_path(@protonym, to_protonym_id: @to_protonym.id),
          notice: "Successfully moved items. Items can be re-ordered at the protonyms page."
      else
        flash.now[:alert] = "Something went wrong... ?"
        render :show, status: :unprocessable_content
      end
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end

      def find_to_protonym
        Protonym.find_by(id: params[:to_protonym_id])
      end

      def history_items
        # Only items of this protonym, so a stale or edited form cannot move another protonym's items.
        @_history_items ||= @protonym.history_items.where(id: params[:history_item_ids]).reorder(:position)
      end
  end
end
