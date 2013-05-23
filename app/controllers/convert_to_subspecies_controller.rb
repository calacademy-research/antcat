# coding: UTF-8
class ConvertToSubspeciesController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def new
    @taxon = Taxon.find params[:taxa_id]
    @new_species = nil
  end

  def create
    @taxon = Taxon.find params[:taxa_id]
    @new_species = Taxon.find_by_name_id params[:new_species_id]

    @taxon.become_subspecies_of @new_species

    render :new
  end

end
