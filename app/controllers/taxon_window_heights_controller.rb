class TaxonWindowHeightsController < ApplicationController

  def update
    session[:taxon_window_height] = params[:taxon_window_height]
    render nothing: true
  end

  # When a User logs in, sometimes the system does a GET on this resource.
  # No idea why.
  def show
    redirect_to '/'
  end

end
