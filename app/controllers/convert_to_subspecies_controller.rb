class ConvertToSubspeciesController < ApplicationController
  before_filter :authenticate_editor

  def new
    @taxon = Taxon.find params[:taxa_id]
    @new_species = nil
    @default_name_string = @taxon.genus.name.name + ' '
  end

  def create
    @taxon = Taxon.find params[:taxa_id]

    if @taxon.kind_of? SpeciesGroupTaxon and @taxon.subspecies.present?
      @taxon.errors.add :base, "This species has subspecies of its own, so it can't be converted to a subspecies"
      render :new and return
    end

    unless params[:new_species_id].present?
      @taxon.errors.add :base, 'Please select a species.'
      render :new and return
    end

    @new_species = Taxon.find_by_name_id params[:new_species_id]

    begin
      @taxon.become_subspecies_of @new_species
    rescue Taxon::TaxonExists => e
      @taxon.errors.add :base, e.message
      render :new and return
    end

    redirect_to catalog_url @taxon
  end

end
