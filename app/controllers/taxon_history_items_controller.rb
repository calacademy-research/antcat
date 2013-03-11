# coding: UTF-8
class TaxonHistoryItemsController < ApplicationController

  def update
    @item = TaxonHistoryItem.find params[:id]
    @item.update_taxt_from_editable params[:taxt_editor]
    json = {
      isNew: false,
      content: render_to_string(partial: 'history_item/panel', locals: {item: @item}),
      id: @item.id,
      success: @item.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
