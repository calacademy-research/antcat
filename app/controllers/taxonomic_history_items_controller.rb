# coding: UTF-8
class TaxonomicHistoryItemsController < ApplicationController

  def update
    @item = TaxonomicHistoryItem.find params[:id]
    @item.update_attribute :taxt, params[:taxt_editor]
    json = {
      isNew: false,
      content: render_to_string(partial: 'catalog/index/history_item/item', locals: {item: @item}),
      id: @item.id,
      success: @item.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
