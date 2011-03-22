require 'snake'

class TaxatryController < ApplicationController
  def index
    @subfamilies = Subfamily.all :order => :name
    set_selected_taxon 'subfamily'
    if @selected_subfamily
      @genera = @selected_subfamily == 'all' ? Genus.all(:order => :name) : @selected_subfamily.genera
      @taxonomic_history = @selected_subfamily.taxonomic_history unless @selected_subfamily == 'all'
    end

    set_selected_taxon 'genus'
    if @selected_genus
      @species = @selected_genus == 'all' ? Species.all(:order => :name) : @selected_genus.species
      @taxonomic_history = @selected_genus.taxonomic_history unless @selected_genus == 'all'
    end

    set_selected_taxon 'species'
    if @selected_species
      @taxonomic_history = @selected_species.taxonomic_history unless @selected_species == 'all'
    end
  end

  def set_selected_taxon rank
    param = params[rank]
    instance_variable_set("@selected_#{rank}", param == 'all' ? 'all' : Taxon.find(param.to_i)) if param
  end
end

