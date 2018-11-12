class TaxonHistoryItemsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:show, :index]
  before_action :ensure_can_edit_catalog, only: [:destroy]
  before_action :set_taxon_history_item, only: [:edit, :update, :destroy]

  def index
    @taxon_history_items = TaxonHistoryItem.all
    @taxon_history_items = @taxon_history_items.search_objects(search_params) if params[:q].present?
    @taxon_history_items = @taxon_history_items.includes(taxon: [:name]).paginate(page: params[:page], per_page: 30)
  end

  def show
    @comparer = TaxonHistoryItem.revision_comparer_for params[:id],
      params[:selected_id], params[:diff_with_id]
  end

  def new
    @item = TaxonHistoryItem.new taxon_id: params[:taxa_id]
  end

  def edit
  end

  def update
    updated = @item.update taxon_history_item_params

    if updated
      @item.create_activity :update, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @item }
      format.html do
        if updated
          redirect_to catalog_path(@item.taxon), notice: "Successfully updated history item."
        else
          render :edit
        end
      end
    end
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
