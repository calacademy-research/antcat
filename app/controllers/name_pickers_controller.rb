# coding: UTF-8
class NamePickersController < ApplicationController

  def index
    respond_to do |format|
      format.json {render json: Taxon.picklist_matching(params[:term]).to_json}
    end
  end

  def show
    name = Name.find params[:id] if params[:id].present?
    render partial: 'show', locals: {name: name}
  end

  def lookup
    taxon = Taxon.find_by_name params[:name]
    if taxon
      id = taxon.id
      name = taxon.name.name
      taxt = Taxt.to_editable_taxon taxon
      error_message = nil
      success = true
    else
      id = taxt = name = nil
      error_message = "The name '#{params[:name]}' was not found"
      success = false
    end
    send_back_json id: id, name: name, taxt: taxt, success: success, error_message: error_message
  end

end
