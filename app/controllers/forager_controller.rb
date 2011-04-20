class ForagerController < ApplicationController

  def index
    @rank = params[:rank]
    @taxon = params[:id] && Taxon.find(params[:id])
    @index_header_taxa = []
    @child_rank = case @rank
                  when 'subfamily': 'genus'
                  else 'subfamily'
                  end

    if @taxon.nil?
      @index_taxa = Subfamily.all
      @browser_taxa = Subfamily.all
    elsif @rank == 'subfamily'
      @index_header_taxa = [:taxon => @taxon, :path => forager_path]
      @index_taxa = @taxon.genera
      @browser_taxa = @taxon.genera
    end
  end

end
