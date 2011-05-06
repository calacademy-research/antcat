class Taxatry::IndexController < TaxatryController

  def show
    super

    @current_path = index_taxatry_path
    @subfamilies = Subfamily.ordered_by_name

    return if @search_results.blank? && params[:id].blank?

    @taxon = Taxon.find params[:id]
    @taxonomic_history = @taxon.taxonomic_history

    case @taxon
    when Subfamily
      @selected_subfamily = @taxon
      @genera = @selected_subfamily.genera
      @selected_genera = nil
      @species = nil
      @selected_species = nil
    when Genus
      @selected_subfamily = @taxon.subfamily
      if @selected_subfamily
        @genera = @selected_subfamily.genera
        subfamily_name = @selected_subfamily.name + ' '
      else
        @genera = [@taxon]
        subfamily_name = ''
      end
      @selected_genus = @taxon
      @species = @taxon.species
      @selected_species = nil
      @taxon_header_name = subfamily_name + '<i>' + @taxon.name + '</i>'
    when Species
      @selected_subfamily = @taxon.genus.subfamily
      @genera = @selected_subfamily.genera if @selected_subfamily
      @selected_genus = @taxon.genus
      @species = @taxon.genus.species
      @selected_species = @taxon
      @taxon_header_name = ''
      @taxon_header_name << @taxon.genus.subfamily.name + ' ' if @taxon.genus.subfamily
      @taxon_header_name << '<i>' + @taxon.genus.name + ' ' + @taxon.name + '</i>'
    end

    @taxon_header_name = @taxon.full_name
    @taxon_header_status = @taxon.status.gsub /_/, ' ' if @taxon.invalid?
  end

end

