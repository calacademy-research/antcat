# coding: UTF-8
class TaxonHistoryItemsController < ApplicationController
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, if: :preview?

  def update
    @item = TaxonHistoryItem.find params[:id]
    @item.update_taxt_from_editable params[:taxt]
    render_json false
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    @item = TaxonHistoryItem.create_taxt_from_editable taxon, params[:taxt]
    render_json true
  end

  def destroy
    @item = TaxonHistoryItem.find params[:id]
    @item.destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  ###

  def render_json is_new
    json = {
      isNew: is_new,
      content: render_to_string(partial: 'history_items/panel', locals: {item: @item}),
      id: @item.id,
      success: @item.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
