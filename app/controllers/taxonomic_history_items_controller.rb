# coding: UTF-8
class TaxonomicHistoryItemsController < ApplicationController
  def update
    TaxonomicHistoryItem.find(params[:id]).update_attribute :taxt, params[:taxt_editor]
    redirect_to index_catalog_path params[:family_id]
  end
end
