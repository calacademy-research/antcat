class TaxatryController < ApplicationController
  def index

    @subfamilies = Taxon.all(:conditions => "rank = 'subfamily'", :order => :name)
    if params[:subfamily]
      if params[:subfamily] == 'all'
        @selected_subfamily = :all
      else
        @selected_subfamily = Taxon.find(params[:subfamily].to_i)
      end
    end

    unless @selected_subfamily.nil?
      if @selected_subfamily == :all
        @tribes = Taxon.all(:conditions => "rank = 'tribe'", :order => :name)
      else
        @tribes = @selected_subfamily.children
      end
    end

    if @tribes
      if params[:tribe]
        @selected_tribe = Taxon.find(params[:tribe].to_i)
      else
        @selected_tribe = @tribes.first
      end
    end

    @genera = @selected_tribe.children if @selected_tribe
  end
end
