# coding: UTF-8
class NamePickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render json: Name.picklist_matching(params[:term]).to_json}
    end
  end

  def show
    name = Name.find params[:id] if params[:id].present?
    render partial: 'show', locals: {name: name}
  end

  def lookup
    name = Name.find_by_name params[:name_string]
    if name
      id = name.id
      name = name.name
      error_message = nil
      success = true
      taxon = Taxon.find_by_name name
      if taxon
        taxon_id = taxon.id
        taxt = Taxt.to_editable_taxon taxon
      else
        taxon_id = taxt = nil
        taxt = Taxt.to_editable_name name
      end
    else
      id = taxt = name = taxon_id = nil
      error_message = "The name '#{params[:name_string]}' was not found"
      success = false
    end
    send_back_json id: id, name: name, taxt: taxt, taxon_id: taxon_id, success: success, error_message: error_message
  end

end
