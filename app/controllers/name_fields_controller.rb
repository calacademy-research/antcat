# coding: UTF-8
class NameFieldsController < NamePickersController

  def find
    data = {success: true}

    name_string = params[:name_string]
    allow_blank = params[:allow_blank].present?
    new_or_homonym = params[:new_or_homonym].present?
    confirming_adding_name = params[:confirm_add_name].present?
    require_existing = params[:require_existing].present?

    if confirming_adding_name
      name = Name.parse name_string
      data[:success] = true
      data[:id] = name.id

    elsif name_string.empty? and allow_blank
      data[:success] = true
      data[:id] = nil

    elsif new_or_homonym
      name = Name.find_by_name name_string
      if !name
        name = Name.parse name_string
        data[:success] = true
        data[:id] = name.id
      else
        data[:success] = false
        data[:id] = name.id
        data[:reason] = 'homonym'
        data[:submit_button_text] = 'Save homonym'
        data[:error_message] = "This name is in use by another taxon. To create a homonym, click \"Save homonym\"."
      end

    else
      name = Name.find_by_name name_string
      if !name
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
      else
        if require_existing
          data[:id] = name.id
          data[:success] = true
        end
      end
    end
  
    data[:content] = render_to_string(partial: 'name_fields/panel', locals: {name_string: name_string})
    json = data.to_json
    render json: json, content_type: 'text/html'
  end

end
