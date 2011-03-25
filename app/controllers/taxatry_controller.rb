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
      @taxon_header_name = @taxon.name
    when Genus
      @selected_subfamily = @taxon.subfamily
      @genera = @selected_subfamily.genera
      @selected_genus = @taxon
      @species = @taxon.species
      @selected_species = nil
      @taxon_header_name = @taxon.subfamily.name + ' ' + '<i>' + @taxon.name + '</i>'
    when Species
      @selected_subfamily = @taxon.genus.subfamily
      @genera = @selected_subfamily.genera
      @selected_genus = @taxon.genus
      @species = @taxon.genus.species
      @selected_species = @taxon
      @taxon_header_name = @taxon.genus.subfamily.name + ' ' + '<i>' + @taxon.genus.name + ' ' + @taxon.name + '</i>'
    end

    @taxon_header_status = @taxon.status.gsub /_/, ' ' if @taxon.invalid?

    render :index
  end

end

