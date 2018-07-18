class ConvertToSubspeciesController < ApplicationController
  before_action :authenticate_editor
  before_action :set_taxon, only: [:new, :create]

  def new
    @default_name_string = @taxon.genus.name.name + ' '
  end

  # TODO move validation to model
  def create
    # Probably? At least according to the UI and the code breaks otherwise
    unless @taxon.is_a? Species
      @taxon.errors.add :base,
        "Taxon to be converted to a subspecies must be of rank species."
      render :new and return
    end

    if @taxon.subspecies.present?
      @taxon.errors.add :base, <<-MSG
        This species has subspecies of its own,
        so it can't be converted to a subspecies
      MSG
      render :new and return
    end

    unless params[:new_species_id].present?
      @taxon.errors.add :base, 'Please select a species.'
      render :new and return
    end

    @new_species = Taxon.find(params[:new_species_id])

    unless @new_species.is_a? Species
      @taxon.errors.add :base, "The new parent must be of rank species."
      render :new and return
    end

    # TODO allow moving to incerae sedis genera
    unless @new_species.genus
      @taxon.errors.add :base, "The new parent must have a genus."
      render :new and return
    end

    # TODO allow converting species to subspecies of other genus?
    # The current model code allows this, but it doesn't change the
    # genus, leading to corrupt data.
    unless @new_species.genus == @taxon.genus
      @taxon.errors.add :base, "The new parent must be in the same genus."
      render :new and return
    end

    begin
      @taxon.become_subspecies_of @new_species
    rescue Taxon::TaxonExists => e
      @taxon.errors.add :base, e.message
      render :new and return
    end

    redirect_to catalog_path(@taxon),
      notice: "Probably converted species to a subspecies."
  end

  private

    def set_taxon
      @taxon = Taxon.find(params[:taxa_id])
    end
end
