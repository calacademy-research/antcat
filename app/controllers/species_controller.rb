class SpeciesController < ApplicationController
  def index
    @species = Species.all(:order => :name).paginate :page => params[:page], :per_page => 100
  end
end
