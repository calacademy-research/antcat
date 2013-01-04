# coding: UTF-8
class TaxonWindowHeightsController < ApplicationController

  def update
    session[:taxon_window_height] = params[:taxon_window_height]
    render nothing: true
  end

end
