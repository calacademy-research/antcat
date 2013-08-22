# coding: UTF-8
class AdvancedSearchesController < ApplicationController

  def show
    taxa = Taxon.advanced_search params[:rank], params[:year], params[:valid_only]
    @taxa = taxa.paginate page: params[:page]
    @taxa_count = taxa.count
  end

end
