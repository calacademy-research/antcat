class TaxonHistoryItemsController < ApplicationController
  before_filter :authenticate_editor
  before_action :set_taxon_history_item, only: [:show, :update, :destroy]

  def show
    render 'history_items/show'
  end

  def update
    @item.update_taxt_from_editable params[:taxt]
    render_json @item
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    UndoTracker.setup_change taxon, :create
    item = TaxonHistoryItem.create_taxt_from_editable taxon, params[:taxt]
    render_json item
  end

  def destroy
    @item.destroy
    render json: { success: true }
  end

  private
    def set_taxon_history_item
      @item = TaxonHistoryItem.find params[:id]
    end

    def render_json item
      json = {
        content: render_to_string(partial: 'history_items/panel', locals: { item: item }),
        id: item.id,
        success: item.errors.empty?
      }
      render json: json
    end
end
