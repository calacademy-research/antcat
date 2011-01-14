class TaxatryController < ApplicationController
  def index
    @subfamily = Taxon.find(params[:subfamily].to_i) if params[:subfamily]
    @tribe = Taxon.find(params[:tribe].to_i) if params[:tribe]
    @genus = Taxon.find(params[:genus].to_i) if params[:genus]

    @subfamilies = Taxon.all(:conditions => "rank = 'subfamily'", :order => :name)
    @tribes = @subfamily.children(:order => :name) if @subfamily
    @genera = @tribe.children(:order => :name) if @tribe
  end
end
