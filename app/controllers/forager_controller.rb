class ForagerController < ApplicationController

  def index
    @rank = params[:rank]
    @taxon = params[:id] && Taxon.find(params[:id])
    @index_header_taxa = []
    @child_rank = case @rank
                  when 'subfamily': 'genus'
                  when 'genus': 'species'
                  else 'subfamily'
                  end

    if @taxon.nil?
      @rank = 'family'
      @taxa = Subfamily.all

    elsif @rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => forager_path, :rank => 'subfamily']
      @taxa = @taxon.genera

    elsif @rank == 'genus'
      @index_header_taxa = [
        {:taxon => @taxon.subfamily, :path => forager_path, :rank => 'subfamily'},
        {:taxon => @taxon, :path => forager_path(:rank => :subfamily, :id => @taxon.subfamily.id), :rank => 'genus'},
      ]
      @taxa = @taxon.species
    end
  end

end
