# frozen_string_literal: true

class HistoryItemsController < ApplicationController
  PER_PAGE_OPTIONS = [30, 100, 500]

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :ensure_user_is_editor, only: [:destroy]

  def index
    scope = HistoryItem.left_joins(:terminal_taxa)
    scope = scope.where(type: params[:type]) if params[:type].present?
    scope = scope.where(taxa: { type: params[:taxon_type] }) if params[:taxon_type].present?
    scope = scope.where(taxa: { status: params[:taxon_status] }) if params[:taxon_status].present?
    scope = HistoryItemQuery.new(scope).search(params[:q], params[:search_type]) if params[:q].present?
    scope = HistoryItemQuery.new(scope).exclude_search(params[:nq], params[:search_type]) if params[:nq].present?
    @history_items = scope.distinct.includes(protonym: [:name]).paginate(page: params[:page], per_page: per_page)
  end

  def show
    @history_item = find_history_item
    @protonym = @history_item.protonym
  end

  def new
    @protonym = find_protonym
    @history_item = @protonym.history_items.new(prefilled_history_item_params)
  end

  def create
    @protonym = find_protonym
    @history_item = @protonym.history_items.new(history_item_params)

    if @history_item.save
      @history_item.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      redirect_url = redirect_back_url || @history_item.protonym
      redirect_to redirect_url, notice: "Successfully added history item " + history_item_link(@history_item) + '.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @history_item = find_history_item
    @protonym = @history_item.protonym
  end

  def update
    @history_item = find_history_item
    @protonym = @history_item.protonym

    updated = @history_item.update(history_item_params)

    if updated
      @history_item.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @history_item, partial: 'taxt_editors/history_item_taxt_editor' }
      format.html do
        if updated
          redirect_url = redirect_back_url || @history_item
          redirect_to redirect_url, notice: "Successfully updated history item " + history_item_link(@history_item) + '.'
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    history_item = find_history_item
    history_item.destroy!
    history_item.create_activity Activity::DESTROY, current_user, edit_summary: params[:edit_summary]

    respond_to do |format|
      format.json do
        render json: { success: true }
      end
      format.html do
        redirect_to history_item.protonym, notice: "Successfully deleted history item."
      end
    end
  end

  private

    def find_protonym
      Protonym.find(params[:protonym_id])
    end

    def find_history_item
      HistoryItem.find(params[:id])
    end

    def history_item_params
      params.require(:history_item).permit(
        :taxt, :rank, :position, :type,
        :subtype, :picked_value, :text_value,
        :reference_id, :pages, :object_protonym_id, :object_taxon_id,
        :force_author_citation
      )
    end

    def prefilled_history_item_params
      params.permit(:position, :type, :subtype, :object_protonym_id, :object_taxon_id)
    end

    def redirect_back_url
      params[:redirect_back_url].presence
    end

    def history_item_link history_item
      view_context.link_to "##{history_item.id}", history_item
    end

    def per_page
      params[:per_page] if params[:per_page].to_i <= PER_PAGE_OPTIONS.max
    end

    def render_json history_item, partial:
      render json: {
        content: render_to_string(
          formats: :html,
          partial: partial,
          locals: { history_item: history_item }
        ),
        error: history_item.errors.full_messages.to_sentence
      }
    end
end
