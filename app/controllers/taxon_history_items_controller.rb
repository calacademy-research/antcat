class TaxonHistoryItemsController < ApplicationController
  before_action :authenticate_editor, except: :show
  before_action :set_taxon_history_item, only: [:update, :destroy]

  def index
    @taxon_history_items = TaxonHistoryItem.all
    @taxon_history_items = @taxon_history_items.search_objects(search_params) if params[:q].present?
    @taxon_history_items = @taxon_history_items.paginate(page: params[:page], per_page: 100)
  end

  def show
    @comparer = TaxonHistoryItem.revision_comparer_for params[:id],
      params[:selected_id], params[:diff_with_id]
  end

  def update
    @item.update_taxt_from_editable params[:taxt]

    if @item.errors.empty?
      @item.create_activity :update, edit_summary: params[:taxon_history_item_edit_summary]
    end

    render_json @item
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    UndoTracker.setup_change taxon, :create
    item = TaxonHistoryItem.create_taxt_from_editable taxon, params[:taxt]

    if item.errors.empty?
      item.create_activity :create, edit_summary: params[:taxon_history_item_edit_summary]
    end

    render_json item
  end

  def destroy
    @item.destroy
    @item.create_activity :destroy

    render json: { success: true }
  end

  private
    def set_taxon_history_item
      @item = TaxonHistoryItem.find params[:id]
    end

    def search_params
      params.slice :search_type, :q
    end

    def render_json item
      json = {
        content: render_to_string(partial: 'taxon_history_items/panel', locals: { item: item }),
        id: item.id,
        success: item.errors.empty?
      }
      render json: json
    end
end
