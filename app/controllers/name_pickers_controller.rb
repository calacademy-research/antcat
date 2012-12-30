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
      success = true
      error_message = nil
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
      success = false
      if params[:confirmed_add_name]
        error_message = "#{params[:name_string]}? has been added. You can attach it to a taxon later, if desired."
      else
        error_message = "Do you want to add the name #{params[:name_string]}? You can attach it to a taxon later, if desired."
      end
    end
    send_back_json id: id, name: name, taxt: taxt, taxon_id: taxon_id, success: success, error_message: error_message
  end

end
