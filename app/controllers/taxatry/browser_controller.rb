class Taxatry::BrowserController < TaxatryController

  def show
    unless params[:id]
      @taxa = Subfamily.all
      return
    end

    @taxon = params[:id] && Taxon.find(params[:id])
    rank = @taxon && @taxon.rank
    @header_taxon = @taxon

    if rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => browser_taxatry_path, :rank => 'subfamily']
      @taxa = @taxon.genera

    elsif rank == 'genus' || rank == 'species'
      if rank == 'species'
        @selected_browser_taxon = @taxon
        @header_taxon = @taxon.genus
      end
      @index_header_taxa = [
        {:taxon => @header_taxon.subfamily, :path => browser_taxatry_path},
        {:taxon => @header_taxon, :path => browser_taxatry_path(@header_taxon.subfamily.id)},
      ]
      @taxa = @header_taxon.species
    end
  end

end
