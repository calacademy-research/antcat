# coding: UTF-8
class NameFieldsController < NamePickersController

  def find
    data = {}

    name_string = params[:name_string]
    allow_blank = params[:allow_blank].present?
    new_or_homonym = params[:new_or_homonym].present?
    confirming_adding_name = params[:confirm_add_name].present?
    require_existing = params[:require_existing].present?

    if confirming_adding_name
      add_name name_string, data

    elsif name_string.empty? and allow_blank
      clear_name data

    elsif new_or_homonym
      name = Name.find_by_name name_string
      if name
        ask_about_homonym name, data
      else
        add_name name_string, data
      end

    else
      name = Name.find_by_name name_string
      if name
        data[:success] = true
        data[:id] = name.id
      else
        if require_existing
          data[:success] = false
          data[:error_message] = 'This must be the name of an existing taxon'
          data[:reason] = 'not found'
        else
          data[:success] = false
          data[:reason] = 'not found'
          data[:submit_button_text] = 'Add this name'
          data[:error_message] = "Do you want to add the name #{name_string}? You can attach it to a taxon later, if desired."
        end
      end
    end
  
    data[:content] = render_to_string(partial: 'name_fields/panel', locals: {name_string: name_string})
    render json: data.to_json, content_type: 'text/html'
  end

  def add_name name_string, data
    name = Name.parse name_string
    data[:success] = true
    data[:id] = name.id
  end

  def clear_name data
    data[:success] = true
    data[:id] = nil
  end

  def ask_about_homonym name, data
    data[:success] = false
    data[:id] = name.id
    data[:reason] = 'homonym'
    data[:submit_button_text] = 'Save homonym'
    data[:error_message] = "This name is in use by another taxon. To create a homonym, click \"Save homonym\"."
  end

end
