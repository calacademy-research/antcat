class NamePopupsController < NamePickersController
  def show
    # TODO see if we can move this ("TAXON_TAG_TYPE").
    if params[:type].to_i == TaxtIdTranslator::TAXON_TAG_TYPE
      taxon = Taxon.find params[:id]
      name = taxon.name
      id = taxon.id
    else
      taxon = nil
      name = Name.find params[:id]
      id = name.id
    end
    render partial: 'show', locals: { id: id, name: name.name }
  end

  def find
    data = {}
    if params[:add_name] == 'true'
      add_name params[:name_string], data
    else
      find_name params[:name_string], data
    end
    send_back_json data
  end

  private

    def find_name name_string, data
      name = Name.find_by_name name_string
      if name
        reply_with_successful_search name, data
      else
        ask_whether_to_add_name name_string, data
      end
    end

    def add_name name_string, data
      name = Names::CreateNameFromString[name_string]
      data[:id] = name.id
      data[:name] = name.name
      data[:taxt] = TaxtIdTranslator.to_editor_nam_tag name
      data[:success] = true
    end

    def ask_whether_to_add_name name_string, data
      data[:success] = false
      data[:error_message] = "Do you want to add the name #{name_string}? You can attach it to a taxon later, if desired."
    end

    def reply_with_successful_search name, data
      data[:id] = name.id
      data[:name] = name.name
      taxon = Taxon.find_by_name data[:name]
      if taxon
        data[:taxon_id] = taxon.id
        data[:taxt] = TaxtIdTranslator.to_editor_tax_tag taxon
      else
        data[:taxt] = TaxtIdTranslator.to_editor_nam_tag name
      end
      data[:success] = true
    end

    def send_back_json hash
      json = hash.to_json
      json = '<textarea>' + json + '</textarea>' unless params[:picker].present? || params[:popup].present? || params[:field].present? || Rails.env.test?
      render json: json
    end
end
