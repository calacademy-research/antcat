class Taxatry::IndexController < TaxatryController

  def show
    super

    @url_parameters = {:q => params[:q], :search_type => params[:search_type], :hide_tribes => params[:hide_tribes]}

    @current_path = index_taxatry_path
    @subfamilies = Subfamily.ordered_by_name

    return if @search_results.blank? && params[:id].blank?

    if params[:id] == 'no_subfamily'
      @taxon = params[:id]
    else
      @taxon = Taxon.find params[:id]
      @taxonomic_history = @taxon.taxonomic_history
    end

    case @taxon
    when 'no_subfamily', Subfamily
      @selected_subfamily = @taxon
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      elsif params[:hide_tribes]
        @genera = @selected_subfamily.genera
      else
        @tribes = @selected_subfamily.tribes
      end

    when Tribe
      @selected_tribe = @taxon
      @tribes = @selected_tribe.siblings
      @genera = @selected_tribe.genera
      @selected_subfamily = @selected_tribe.subfamily

    when Genus
      @selected_genus = @taxon
      @selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      else
        @genera = @selected_genus.siblings
      end
      @species = @selected_genus.species
      unless params[:hide_tribes]
        @selected_tribe = @selected_genus.tribe || 'no_tribe'
        @tribes = @selected_tribe.siblings unless @selected_tribe == 'no_tribe'
      end

    when Species
      @selected_species = @taxon
      @species = @selected_species.siblings
      @selected_subfamily = @selected_species.subfamily || 'no_subfamily'
      @selected_genus = @selected_species.genus
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      else
        @genera = @selected_genus.siblings
      end
      unless params[:hide_tribes]
        @selected_tribe = @selected_genus.tribe || 'no_tribe'
        @tribes = @selected_tribe.siblings unless @selected_tribe == 'no_tribe'
      end

    end

    @taxon_header_name = @taxon.full_name if @taxon.kind_of? Taxon
  end

end

