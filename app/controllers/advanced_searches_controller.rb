# coding: UTF-8
class AdvancedSearchesController < ApplicationController

  def show
    @taxa = Taxon.advanced_search(params[:rank], params[:year], params[:valid_only]).paginate page: params[:page]
  end

end
