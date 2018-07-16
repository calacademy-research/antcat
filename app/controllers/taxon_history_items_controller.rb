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

  def new
    @item = TaxonHistoryItem.new taxon_id: params[:taxa_id]
  end

  def update
    if @item.update taxon_history_item_params
      @item.create_activity :update, edit_summary: params[:edit_summary]
    end

    render_json @item
  end

  def create
    @item = TaxonHistoryItem.new taxon_history_item_params
    @item.taxon_id = params[:taxa_id]

    if @item.save
      @item.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to edit_taxa_path(@item.taxon), notice: "Successfully added history item."
    else
      render :new
    end
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

    def taxon_history_item_params
      params.require(:taxon_history_item).permit(:taxt)
    end

    def render_json item
      json = {
        content: render_to_string(partial: 'taxon_history_items/taxt_editor_template', locals: { item: item }),
        error: item.errors.full_messages.to_sentence
      }
      render json: json
    end
end
