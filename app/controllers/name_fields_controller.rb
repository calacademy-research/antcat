class NameFieldsController < NamePickersController
  def find
    data = {}

    name_string = params[:name_string]
    allow_blank = params[:allow_blank].present?
    new_or_homonym = params[:new_or_homonym].present?
    require_new = params[:require_new].present?
    require_existing = params[:require_existing].present?

    confirming_adding_name = params[:confirm_add_name].present?

    if confirming_adding_name
      add_name name_string, data

    elsif name_string.empty? and allow_blank
      clear_name data

    elsif new_or_homonym
      name = Name.find_by_name name_string
      if name
        if Taxon.find_by_name_id name.id
          ask_about_homonym name, data
        else
          add_name name_string, data
        end
      else
        add_name name_string, data
      end

    elsif require_new
      name = Name.find_by_name name_string
      if name
        if Taxon.find_by_name_id name.id
          tell_about_existing name, data
        else
          add_name name_string, data
        end
      else
        add_name name_string, data
      end

    else
      name = Name.find_by_name name_string
      if name
        accept_success name, data
      else
        if require_existing
          tell_existing_required data
        else
          ask_about_adding name_string, data
        end
      end
    end

    data[:content] = render_to_string(partial: 'name_fields/panel', locals: { name_string: name_string })
    render json: data
  end

  # TODO joe - this is probably where we should handle the cases currently done in
  # a combination of duplicatescontroller and name_field.coffee

  private
    def add_name name_string, data
      name = Names::Parser.create_name_from_string! name_string
      data[:success] = true
      data[:id] = name.id
    end

    def clear_name data
      data[:success] = true
      data[:id] = nil
    end

    def tell_about_existing _name, data
      data[:success] = false
      data[:error_message] = "This name is in use by another taxon."
      data[:reason] = 'homonym'
    end

    def ask_about_homonym name, data
      data[:success] = false
      data[:id] = name.id
      data[:reason] = 'homonym'
      data[:submit_button_text] = 'Save homonym'
      data[:error_message] = 'This name is in use by another taxon. To create a homonym, click "Save homonym".'
    end

    def accept_success name, data
      data[:success] = true
      data[:id] = name.id
    end

    def tell_existing_required data
      data[:success] = false
      data[:error_message] = 'This must be the name of an existing taxon'
      data[:reason] = 'not found'
    end

    def ask_about_adding name_string, data
      data[:success] = false
      data[:reason] = 'not found'
      data[:submit_button_text] = 'Add this name'
      data[:error_message] = "Do you want to add the name #{name_string}? You can attach it to a taxon later, if desired."
    end
end
