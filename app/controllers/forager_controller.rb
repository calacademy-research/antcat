class ForagerController < ApplicationController

  before_filter :search

  def show
    unless params[:id]
      @taxa = Subfamily.all
      return
    end

    @taxon = params[:id] && Taxon.find(params[:id])
    rank = @taxon && @taxon.rank
    @header_taxon = @taxon

    if rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => forager_path, :rank => 'subfamily']
      @taxa = @taxon.genera

    elsif rank == 'genus' || rank == 'species'
      if rank == 'species'
        @selected_browser_taxon = @taxon
        @header_taxon = @taxon.genus
      end
      @index_header_taxa = [
        {:taxon => @header_taxon.subfamily, :path => forager_path},
        {:taxon => @header_taxon, :path => forager_path(@header_taxon.subfamily.id)},
      ]
      @taxa = @header_taxon.species
    end
  end

  def search
    if params['commit'] == 'Clear'
      params['q'] = params['search_type'] = nil
      return
    end

    if params['q'].present?
      params['id'] = nil if params['commit'] == 'Go'
      @search_results = Taxon.find_name params['q'], params['search_type']
      unless @search_results.present?
        @search_results_message = "No results found"
      else
        @search_results = @search_results.map do |search_result|
          {:name => search_result.full_name, :id => search_result.id}
        end.sort_by {|element| element[:name]}
        params['id'] = @search_results.first[:id] if params['id'].blank?
        show
        true
      end
    end
  end

end
