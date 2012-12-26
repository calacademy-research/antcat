# coding: UTF-8
class NamePickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render json: Taxon.picklist_matching(params[:term]).to_json}
    end
  end

  def lookup
    taxon = Taxon.find_by_name params[:name]
    if taxon
      taxt = Taxt.to_editable_taxon taxon
      error_message = nil
      success = true
    else
      taxt = nil
      error_message = "The name '#{params[:name]}' was not found"
      success = false
    end
    send_back_json id: id, taxt: taxt, success: success, error_message: error_message
  end

end
