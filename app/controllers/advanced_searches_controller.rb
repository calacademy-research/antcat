# coding: UTF-8
class AdvancedSearchesController < ApplicationController

  def show
    @taxa = Taxon.advanced_search(params[:rank], params[:year]).paginate page: params[:page]
    render 'advanced_search/index'
  end

end
