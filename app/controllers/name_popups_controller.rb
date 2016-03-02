class NamePopupsController < NamePickersController

  def show
    if params[:type].to_i == Taxt::TAXON_TAG_TYPE
      taxon = Taxon.find params[:id]
      name = taxon.name
      id = taxon.id
    else
      taxon = nil
      name = Name.find params[:id]
      id = name.id
    end
    render partial: 'show', locals: {id: id, name: name.name}
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

  ##########

  def find_name name_string, data
    name = Name.find_by_name name_string
    if name
      reply_with_successful_search name, data
    else
      ask_whether_to_add_name name_string, data
    end
  end

  def add_name name_string, data
    name = Name.parse name_string
    data[:id] = name.id
    data[:name] = name.name
    data[:taxt] = Taxt.to_editable_name name
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
      data[:taxt] = Taxt.to_editable_taxon taxon
    else
      data[:taxt] = Taxt.to_editable_name name
    end
    data[:success] = true
  end

end
