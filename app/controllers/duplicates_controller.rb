# Controller to handle the duplicates cases -
# cases where a species move from one genus to anohter - starting off in
# genus A, moving to genus B, and then back to A, while retaining the same
# species epithet.

class DuplicatesController < TaxaController
  before_filter :authenticate_editor, :get_params

  # Takes requires parent_id (target parent)and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
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
    render json: options.to_json, status: :ok
  end

  def update

  end


end