# coding: UTF-8
class TaxaController < ApplicationController

  def new
  end

  def create
  end

  def edit
    @taxon = Taxon.find params[:id]
  end

  def update
    @taxon = Taxon.find params[:id] 
  end

end
