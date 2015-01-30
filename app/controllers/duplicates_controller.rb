# Controller to handle the duplicates cases -
# cases where a species move from one genus to anohter - starting off in
# genus A, moving to genus B, and then back to A, while retaining the same
# species epithet.

class DuplicatesController < TaxaController
  before_filter :authenticate_editor, :get_params, :create_mother


  # Takes requires parent_id (target parent)and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
  def show
    if @rank_to_create != Rank['species']
      render :nothing => true, status: :no_content
      return
    end
    current_taxon = Taxon.find(params[:current_taxon_id])
    new_parent = Taxon.find_by_name_id(params[:new_parent_name_id])
    if(current_taxon.rank == Rank['subspecies'].to_s)
      # searching for genus / subspecies for conflict.
      options = Taxon.find_subspecies_in_genus current_taxon.name.epithet, new_parent.parent
    else
      options = Taxon.find_epithet_in_genus current_taxon.name.epithet, new_parent
    end



    if options.nil?
      render :nothing => true, status: :no_content
      return
    end
    # TODO: Rails 4 requires that authorship_String and duplicate_type be db columns. Refactor
    # This code to pass these some other way, and remove these two columns from the taxa db entry
    options.each do |option|
      # Todo: Joe calls to protonym.authorship_string trigger a save somehow
      option[:authorship_string] = option.protonym.authorship_string

      #Todo: joe check page number case?

      # Used to pop up the correct dialog box content in the name_field.coffee widget

      # in the case of "return to original" - give the option of actually returning to
      # original, creating a secondary junior homonym, or cancel

      # in the case of "secondary junior homonym" - give that option, or cancel.
      if (option.protonym.id == current_taxon.protonym.id)
        duplicate_type = 'return_to_original'
      else
        duplicate_type = 'secondary_junior_homonym'
      end
      option['duplicate_type'] = duplicate_type
    end
    render json: options.to_json, status: :ok
  end


end





