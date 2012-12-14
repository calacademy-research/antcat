# coding: UTF-8
class TaxonPickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render :json => Taxon.names_and_authorships(params[:term]).to_json}
    end
  end

  def lookup
    taxon = Taxon.find_by_name params[:taxon_name]
    if taxon
      taxt = Taxt.to_editable_taxon taxon
      success = true
    else
      taxt = nil
      success = false
    end
    send_back_json {{taxt: taxt, success: success}}
  end

end
