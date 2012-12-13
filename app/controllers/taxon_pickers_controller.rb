# coding: UTF-8
class TaxonPickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render :json => Taxon.names_and_authorships(params[:term]).to_json}
    end
  end

  def lookup
    json = {taxt: "Mark's the best", success: true}.to_json
    json = '<textarea>' + json + '</textarea>' unless
      params[:picker].present? || params[:field].present? || Rails.env.test?
    render json: json, content_type: 'text/html'
  end

end
