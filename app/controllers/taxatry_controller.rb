class TaxatryController < ApplicationController
  def index

    @subfamilies = Taxon.all(:conditions => "rank = 'subfamily'", :order => :name)
    if params[:subfamily]
      @selected_subfamily = Taxon.find(params[:subfamily].to_i)
    else
      @selected_subfamily = @subfamilies.first
    end

    @tribes = @selected_subfamily.children
    if params[:tribe]
      @selected_tribe = Taxon.find(params[:tribe].to_i)
    else
      @selected_tribe = @tribes.first
    end

    @genera = @selected_tribe.children if @selected_tribe
  end
end
