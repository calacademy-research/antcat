# coding: UTF-8
class ConvertToSubspeciesController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def new
    @taxon = Taxon.find params[:taxa_id]
  end

  def create
    @taxon = Taxon.find params[:taxa_id]
  end

end
