class TaxonHistoryItemsController < ApplicationController
  PER_PAGE_OPTIONS = [30, 100, 500]

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :ensure_user_is_editor, only: [:destroy]

  def index
    @taxon_history_items = TaxonHistoryItem.joins(:taxon)
    @taxon_history_items = @taxon_history_items.where(taxa: { type: params[:taxon_type] }) if params[:taxon_type].present?
    @taxon_history_items = @taxon_history_items.where(taxa: { status: params[:taxon_status] }) if params[:taxon_status].present?
    @taxon_history_items = @taxon_history_items.search(params[:q], params[:search_type]) if params[:q].present?
    @taxon_history_items = @taxon_history_items.includes(taxon: [:name]).paginate(page: params[:page], per_page: per_page)
  end

  def show
    @taxon_history_item = find_taxon_history_item
    @taxon = @taxon_history_item.taxon
  end

  def new
    @taxon = find_taxon
    @taxon_history_item = @taxon.history_items.new
  end

  def create
    @taxon = find_taxon
    @taxon_history_item = @taxon.history_items.new(taxon_history_item_params)

    if @taxon_history_item.save
      @taxon_history_item.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to edit_taxa_path(@taxon_history_item.taxon), notice: "Successfully added history item."
    else
      render :new
    end
  end

  def edit
    @taxon_history_item = find_taxon_history_item
    @taxon = @taxon_history_item.taxon
  end

  def update
    @taxon_history_item = find_taxon_history_item
    @taxon = @taxon_history_item.taxon

    updated = @taxon_history_item.update(taxon_history_item_params)

    if updated
      @taxon_history_item.create_activity :update, current_user, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @taxon_history_item }
      format.html do
        if updated
          redirect_to @taxon_history_item, notice: "Successfully updated history item."
        else
          render :edit
        end
      end
    end
  end

  def destroy
    taxon_history_item = find_taxon_history_item
    taxon_history_item.destroy
    taxon_history_item.create_activity :destroy, current_user, edit_summary: params[:edit_summary]

    respond_to do |format|
      format.json do
        render json: { success: true }
      end
      format.html do
        redirect_to catalog_path(taxon_history_item.taxon), notice: "Successfully deleted history item."
      end
    end
  end

  private

    def find_taxon
      Taxon.find(params[:taxa_id])
    end

    def find_taxon_history_item
      TaxonHistoryItem.find(params[:id])
    end

    def taxon_history_item_params
      params.require(:taxon_history_item).permit(:taxt)
    end

    def per_page
      params[:per_page] if params[:per_page].to_i <= PER_PAGE_OPTIONS.max
    end

    def render_json taxon_history_item
      render json: {
        content: render_to_string(partial: 'taxon_history_items/taxt_editor_template', locals: { taxon_history_item: taxon_history_item }),
        error: taxon_history_item.errors.full_messages.to_sentence
      }
    end
end
