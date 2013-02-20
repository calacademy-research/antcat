# coding: UTF-8
class NameFieldsController < ApplicationController

  def search
    respond_to do |format|
      format.json {render json: Name.picklist_matching(params[:term]).to_json}
    end
  end

  def show
    id = params[:id]
    name = Name.find params[:id]
    render partial: 'show', locals: {name: name}
  end

  def find
    data = {}
    if params[:add_name] == 'true'
      name = add_name params[:name_string], data
    else
      name = find_name params[:name_string], data
    end
    data.merge!(
      content: render_to_string(partial: 'name_fields/panel', locals: {name: name}),
      success: name.errors.empty?)
    json = data.to_json

    render json: json, content_type: 'text/html'
  end

  ##########

  def find_name name_string, data
    name = Name.find_by_name name_string
    if name
      data[:success] = true
    else
      ask_whether_to_add_name name_string, data
    end
    name
  end

  def add_name name_string, data
    name = Name.parse name_string
    data[:success] = true
    name
  end

  def ask_whether_to_add_name name_string, data
    data[:success] = false
    data[:error_message] = "Do you want to add the name #{name_string}? You can attach it to a taxon later, if desired."
  end

  def reply_with_successful_search name, data
    data[:success] = true
  end

end
