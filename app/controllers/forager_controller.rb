class ForagerController < ApplicationController

  def show
    unless params[:id]
      @taxa = Subfamily.all
      return
    end

    @taxon = params[:id] && Taxon.find(params[:id])
    rank = @taxon && @taxon.rank

    if rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => forager_path, :rank => 'subfamily']
      @taxa = @taxon.genera

    elsif rank == 'genus'
      @index_header_taxa = [
        {:taxon => @taxon.subfamily, :path => forager_path},
        {:taxon => @taxon, :path => forager_path(@taxon.subfamily.id)},
      ]
      @taxa = @taxon.species
    end
  end

end
