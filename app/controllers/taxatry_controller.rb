class TaxatryController < ApplicationController
  def index
    @selected_supersubfamily = params[:supersubfamily]
    @selected_subfamily = params[:subfamily]
    @selected_tribe = params[:tribe]
  end
end
