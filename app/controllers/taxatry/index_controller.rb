class Taxatry::IndexController < TaxatryController

  def show
    super

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
      @genera = @selected_subfamily == 'no_subfamily' ? Genus.without_subfamily : @selected_subfamily.genera
      @selected_genera = nil
      @species = nil
      @selected_species = nil
    when Genus
      @selected_subfamily = @taxon.subfamily || 'no_subfamily'
      if @selected_subfamily.kind_of? Taxon
        @genera = @selected_subfamily.genera
      else
        @genera = Genus.without_subfamily
      end
      @selected_genus = @taxon
      @species = @taxon.species
      @selected_species = nil
    when Species
      @selected_subfamily = @taxon.genus.subfamily || 'no_subfamily'
      @genera = @selected_subfamily == 'no_subfamily' ? Genus.without_subfamily : @selected_subfamily.genera
      @selected_genus = @taxon.genus
      @species = @taxon.genus.species
      @selected_species = @taxon
    end

    @taxon_header_name = @taxon.full_name if @taxon.kind_of? Taxon
  end

end

