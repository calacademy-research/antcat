# coding: UTF-8
class NameFieldsController < NamePickersController

  def find
    data = {}
    clearing_name = false

    adding_name = params[:add_name] == 'true'
    name_string = params[:name_string]
    allow_blank = params[:allow_blank].present?
    require_existing = params[:require_existing].present?

    if adding_name
      name = add_name name_string, data
    elsif name_string.empty? and allow_blank
      clearing_name = true
    else
      name = find_name name_string, require_existing, data
    end

    id = name.try :id
    value = name.try :id
    name_string = name.try(:name) || name_string

    if name
      success = name.errors.empty?
    elsif clearing_name
      success = true
    else
      success = false
    end
    options = {}
    options[:allow_blank] = true if allow_blank
    options[:require_existing] = true if require_existing
    data.merge!(
      content: render_to_string(partial: 'name_fields/panel', locals: {name_string: name_string, options: options}),
      success: success,
      id: id)
    json = data.to_json

    render json: json, content_type: 'text/html'
  end

  ##########

  def find_name name_string, require_existing, data
    name = Name.find_by_name name_string
    if name
      data[:success] = true
    elsif require_existing
      data[:success] = false
      data[:error_message] = 'This must be the name of an existing taxon'
      data[:reason_for_error] = 'taxon not found'
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
