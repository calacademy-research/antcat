class Catalog::IndexController < CatalogController

  def show
    super

    @current_path = index_catalog_path
    @subfamilies = ::Subfamily.ordered_by_name

    @url_parameters = {:q => params[:q], :search_type => params[:search_type], :hide_tribes => params[:hide_tribes]}

    return if @search_results.blank? && params[:id].blank?

    if params[:id] =~ /^no_/
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

    when 'no_tribe', Tribe
      @selected_tribe = @taxon
      if params[:hide_tribes] && @selected_tribe == 'no_tribe'
        @taxon = ::Subfamily.find params[:subfamily]
        @selected_subfamily = @taxon
        @genera = @selected_subfamily.genera
      elsif params[:hide_tribes]
        @taxon = @selected_tribe.subfamily
        @selected_subfamily = @taxon
        @genera = @selected_subfamily.genera
      elsif @selected_tribe == 'no_tribe'
        @selected_subfamily = ::Subfamily.find params[:subfamily]
        @tribes = @selected_subfamily.tribes
        @genera = @selected_subfamily.genera.without_tribe
      else
        @tribes = @selected_tribe.siblings
        @genera = @selected_tribe.genera
        @selected_subfamily = @selected_tribe.subfamily
      end

    when Genus
      @selected_genus = @taxon
      @selected_subfamily = @selected_genus.subfamily || 'no_subfamily'
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      else
        @genera = @selected_genus.siblings
      end
      @species = @selected_genus.species
      unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
        @selected_tribe = @selected_genus.tribe || 'no_tribe'
        @tribes = @selected_subfamily.tribes
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
      unless params[:hide_tribes] || @selected_subfamily == 'no_subfamily'
        @selected_tribe = @selected_genus.tribe || 'no_tribe'
        @tribes = @selected_subfamily.tribes
      end

    end

    @url_parameters[:subfamily] = @selected_subfamily

    @taxon_header_name = @taxon.full_name if @taxon.kind_of? Taxon
  end

end

