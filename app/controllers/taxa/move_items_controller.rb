module Taxa
  class MoveItemsController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon
    before_action :set_to_taxon, only: [:show, :create]

    def new
    end

    def show
      unless @to_taxon
        redirect_to({ action: :new }, alert: "Target must be specified.")
      end
    end

    def create
      if history_items.empty?
        flash.now[:alert] = "At least one item must be selected."
        render :show
        return
      end

      activity_parameters = activity_parameters_before_change

      if Taxa::Operations::MoveItems[@to_taxon, history_items]
        create_activity(activity_parameters)
        redirect_to taxa_move_items_path(@taxon, to_taxon_id: @to_taxon.id),
          notice: "Successfully moved history items. Items can be re-ordered at the taxon's edit page."
      else
        flash.now[:alert] = "Something went wrong... ?"
        render :show
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_to_taxon
        @to_taxon = Taxon.find_by(id: params[:to_taxon_id])
      end

      def history_items
        @history_items ||= TaxonHistoryItem.where(id: params[:history_item_ids])
      end

      def create_activity(parameters)
        @taxon.create_activity :move_items, parameters: parameters
      end

      def activity_parameters_before_change
        {
          to_taxon_id: @to_taxon.id,
          history_items_was: [history_items.pluck(:id, :position)]
        }
      end
  end
end
