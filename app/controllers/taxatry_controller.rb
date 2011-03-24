require 'snake'

class TaxatryController < ApplicationController

  def index
    @taxon = nil
    @taxonomic_history = nil

    @subfamilies = Subfamily.all :order => :name
    @selected_subfamily = nil

    @genera = nil
    @selected_genera = nil
    
    @species = nil
    @selected_species = nil
  end

  def show
    @taxon = Taxon.find params[:id]
    @taxonomic_history = @taxon.taxonomic_history

    @subfamilies = Subfamily.all :order => :name

    case @taxon
    when Subfamily
      @selected_subfamily = @taxon
      @genera = @selected_subfamily.genera
      @selected_genera = nil
      @species = nil
      @selected_species = nil
    when Genus
      @selected_subfamily = @taxon.subfamily
      @genera = @selected_subfamily.genera
      @selected_genus = @taxon
      @species = @taxon.species
      @selected_species = nil
    when Species
      @selected_subfamily = @taxon.genus.subfamily
      @genera = @selected_subfamily.genera
      @selected_genus = @taxon.genus
      @species = @taxon.genus.species
      @selected_species = @taxon
    end

    render :index
  end

end

