# coding: UTF-8
class TaxonPickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render :json => Taxon.names_and_authorships(params[:term]).to_json}
    end
  end

end
