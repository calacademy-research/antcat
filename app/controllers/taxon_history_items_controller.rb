class TaxonHistoryItemsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:show, :index]
  before_action :ensure_user_is_editor, only: [:destroy]
  before_action :set_taxon_history_item, only: [:show, :edit, :update, :destroy]

  def index
    @taxon_history_items = TaxonHistoryItem.all
    @taxon_history_items = @taxon_history_items.search_objects(search_params) if params[:q].present?
    @taxon_history_items = @taxon_history_items.includes(taxon: [:name]).paginate(page: params[:page], per_page: 30)
  end

  def show
  end

  def new
    @taxon_history_item = TaxonHistoryItem.new(taxon_id: params[:taxa_id])
  end

  def edit
  end

  def update
    updated = @taxon_history_item.update(taxon_history_item_params)

    if updated
      @taxon_history_item.create_activity :update, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @taxon_history_item }
      format.html do
        if updated
          redirect_to catalog_path(@taxon_history_item.taxon), notice: "Successfully updated history item."
        else
          render :edit
        end
      end
    end
  end

  def create
    @taxon_history_item = TaxonHistoryItem.new(taxon_history_item_params)
    @taxon_history_item.taxon_id = params[:taxa_id]

    if @taxon_history_item.save
      @taxon_history_item.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to edit_taxa_path(@taxon_history_item.taxon), notice: "Successfully added history item."
    else
      render :new
    end
  end

  def destroy
    @taxon_history_item.destroy
    @taxon_history_item.create_activity :destroy, edit_summary: params[:edit_summary]

    render json: { success: true }
  end

  private

    def set_taxon_history_item
      @taxon_history_item = TaxonHistoryItem.find(params[:id])
    end

    def search_params
      params.slice :search_type, :q
    end

    def taxon_history_item_params
      params.require(:taxon_history_item).permit(:taxt)
    end

    def render_json taxon_history_item
      render json: {
        content: render_to_string(partial: 'taxon_history_items/taxt_editor_template', locals: { taxon_history_item: taxon_history_item }),
        error: taxon_history_item.errors.full_messages.to_sentence
      }
    end
end
