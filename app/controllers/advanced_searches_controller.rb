# coding: UTF-8
class AdvancedSearchesController < ApplicationController

  def show
    if params[:rank].present?
      @taxa = Taxon.advanced_search author_name: params[:author_name], rank: params[:rank], year: params[:year], valid_only: params[:valid_only]
      @taxa_count = @taxa.count
    end
  end

end
