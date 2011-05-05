class Taxatry::BrowserController < TaxatryController

  def show
    super

    unless params[:id]
      @taxa = Subfamily.order(:name).all
      return
    end

    @taxon = params[:id] && Taxon.find(params[:id])
    rank = @taxon && @taxon.rank
    @header_taxon = @taxon

    if rank.nil?
      @index_header_taxa = [:taxon => @taxon, :path => browser_taxatry_path(nil, @search_params)]

    elsif rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => browser_taxatry_path(@taxon, @search_params)]
      @taxa = @taxon.genera.not_homonyms

    elsif rank == 'genus' || rank == 'species'
      if rank == 'species'
        @selected_browser_taxon = @taxon
        @header_taxon = @taxon.genus
      end
      @index_header_taxa = []
      if @header_taxon.subfamily
        @index_header_taxa = [
          {:taxon => @header_taxon.subfamily, :path => browser_taxatry_path(@header_taxon.subfamily, @search_params)},
          {:taxon => @header_taxon, :path => browser_taxatry_path(@header_taxon, @search_params)},
        ]
      end
      @taxa = @header_taxon.species
    end
  end

end
