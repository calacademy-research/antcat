class DuplicatesController < TaxaController
  before_filter :authenticate_editor, :get_params

  def show
    if @rank_to_create != Rank['species']
      render :nothing => true, status: :no_content
      return
    end

    new_parent = Taxon.find(@parent_id)
    options = Taxon.find_epithet_in_genus @previous_combination.name.epithet, new_parent

    options.each do |option|
      # puts "name: " + option.name.name + " " +
      #          "author: " + option.protonym.authorship_string  +
      #          " id: " + option[:id].to_s
      # puts "protonym id : " + option.protonym[:id].to_s
      option[:authorship_string] = option.protonym.authorship_string
    end
    render json: options.to_json, status: 500
  end


end