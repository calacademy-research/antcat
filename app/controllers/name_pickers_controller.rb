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
    data = {}
    if params[:add_name] == 'true'
      add_name params[:name_string], data
    else
      name = Name.find_by_name params[:name_string]
      if name
        send_back_successful_search name, data
      else
        data[:success] = false
        data[:error_message] = "Do you want to add the name #{params[:name_string]}? You can attach it to a taxon later, if desired."
      end
    end
    send_back_json data
  end

  def add_name name_string, data
    name = Name.parse name_string
    data[:id] = name.id
    data[:name] = name.name
    data[:taxt] = Taxt.to_editable_name name
    data[:success] = true
  end

  def send_back_successful_search name, data
    data[:id] = name.id
    data[:name] = name.name
    taxon = Taxon.find_by_name data[:name]
    if taxon
      data[:taxon_id] = taxon.id
      data[:taxt] = Taxt.to_editable_taxon taxon
    else
      data[:taxt] = Taxt.to_editable_name name
    end
    data[:success] = true
  end

end
