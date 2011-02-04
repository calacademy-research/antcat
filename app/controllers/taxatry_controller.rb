require 'snake'

class TaxatryController < ApplicationController
  def index
    @show_tribes = params[:show_tribes] != 'false'

    @subfamilies = Subfamily.all :order => :name
    set_selected_taxon 'subfamily'

    if @show_tribes
      if @selected_subfamily
        @tribes = @selected_subfamily == 'all' ? Tribe.all(:order => :name) : @selected_subfamily.tribes
        set_selected_taxon 'tribe'
      end
      @genera = @selected_tribe.genera if @selected_tribe

    elsif @selected_subfamily
      @genera = @selected_subfamily == 'all' ? Genus.all(:order => :name) : @selected_subfamily.genera

    end
    set_selected_taxon 'genus'

    if @selected_genus
      @species = @selected_genus.species
    end
  end

  def set_selected_taxon rank
    param = params[rank]
    instance_variable_set("@selected_#{rank}", param == 'all' ? 'all' : Taxon.find(param.to_i)) if param
  end
end

