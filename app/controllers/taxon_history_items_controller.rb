class TaxonHistoryItemsController < ApplicationController
  include UndoTracker

  before_filter :authenticate_editor

  def update
    @item = TaxonHistoryItem.find params[:id]
    @item.update_taxt_from_editable params[:taxt]
    render_json is_new: false
  end

  def create
    @taxon = Taxon.find params[:taxa_id]
    setup_change :create
    @item = TaxonHistoryItem.create_taxt_from_editable @taxon, params[:taxt]
    render_json is_new: true
  end

  def destroy
    @item = TaxonHistoryItem.find params[:id]
    @item.destroy
    json = { success: true }
    render json: json, content_type: 'text/html'
  end

  private
    def render_json(is_new:)
      json = {
        isNew: is_new,
        content: render_to_string(partial: 'history_items/panel', locals: { item: @item }),
        id: @item.id,
        success: @item.errors.empty?
      }

      render json: json, content_type: 'text/html'
    end

end
