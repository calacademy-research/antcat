# coding: UTF-8
class Catalog::BrowserController < CatalogController

  def show
    super

    if !params[:id] || Taxon.find(params[:id]).kind_of?(Family)
      @taxa = ::Subfamily.order(:name).all
      return
    end

    @taxon = params[:id] && Taxon.find(params[:id])

    @taxon = @taxon.subfamily if @taxon.kind_of?(Tribe)

    @header_taxon = @taxon

    case @taxon
    when Subfamily
      @index_header_taxa = [taxon: @taxon, path: browser_catalog_path(@taxon, @search_params)]
      @taxa = @taxon.genera.valid

    when Genus, Species
      if @taxon.kind_of? Species
        @selected_browser_taxon = @taxon
        @header_taxon = @taxon.genus
      end
      @index_header_taxa = []
      if @header_taxon.subfamily
        @index_header_taxa = [
          {taxon: @header_taxon.subfamily, path: browser_catalog_path(@header_taxon.subfamily, @search_params)},
          {taxon: @header_taxon, path: browser_catalog_path(@header_taxon, @search_params)},
        ]
      end
      @taxa = @header_taxon.species
    end
  end

end
