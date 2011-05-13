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
        @tribes = @taxon.tribes
      end

    when Tribe
      @selected_subfamily = @taxon.subfamily
      @tribes = @taxon.siblings
      @selected_tribe = @taxon
      @genera = @taxon.genera

    when Genus
      @selected_subfamily = @taxon.subfamily || 'no_subfamily'
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      else
        @tribes = @taxon.tribe.siblings
        @selected_tribe = @taxon.tribe
        @genera = @taxon.siblings
      end
      @selected_genus = @taxon
      @species = @taxon.species

    when Species
      @selected_subfamily = @taxon.subfamily || 'no_subfamily'
      if @selected_subfamily == 'no_subfamily'
        @genera = Genus.without_subfamily
      else
        @tribes = @taxon.genus.tribe.siblings
        @selected_tribe = @taxon.genus.tribe
        @genera = @taxon.genus.siblings
      end
      @selected_genus = @taxon.genus
      @species = @taxon.siblings
      @selected_species = @taxon

    end

    @taxon_header_name = @taxon.full_name if @taxon.kind_of? Taxon
  end

end

