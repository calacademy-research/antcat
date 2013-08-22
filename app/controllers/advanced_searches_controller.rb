# coding: UTF-8
class AdvancedSearchesController < ApplicationController

  def show
    if params[:rank].present?
      @taxa = Taxon.advanced_search params[:rank], params[:year], params[:valid_only]
      @taxa_count = @taxa.count
    end
  end

end
