# Controller to handle the duplicates cases -
# cases where a species move from one genus to anohter - starting off in
# genus A, moving to genus B, and then back to A, while retaining the same
# species epithet.

class DuplicatesController < TaxaController
  before_filter :authenticate_editor

  # Takes requires parent_id (target parent)and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
  def show
    return find_name_duplicates_only if params['match_name_only'] == "true"

    # This check shouldn't be valid; there's nothing wrong with
    # a conflict in a subspecies parent, for example.
    # if @rank_to_create != "species"
    #   render :nothing => true, status: :no_content
    #   return
    # end
    current_taxon = Taxon.find(params[:current_taxon_id])
    new_parent = Taxon.find_by_name_id(params[:new_parent_name_id])
    if current_taxon.is_a? Subspecies
      # searching for genus / subspecies for conflict.
      options = Taxa::Utility.find_subspecies_in_genus current_taxon.name.epithet, new_parent.parent
    else
      options = Taxa::Utility.find_epithet_in_genus current_taxon.name.epithet, new_parent
    end
    render nothing: true, status: :no_content and return unless options

    # This code to pass these some other way, and remove these two columns from the taxa db entry
    options.each do |option|
      # TODO: Joe calls to protonym.authorship_string trigger a save somehow
      option.authorship_string = option.protonym.authorship_string

      # TODO: joe check page number case?
      # Used to pop up the correct dialog box content in the name_field.coffee widget
      # in the case of "return to original" - give the option of actually returning to
      # original, creating a secondary junior homonym, or cancel
      # in the case of "secondary junior homonym" - give that option, or cancel.
      option.duplicate_type = if option.protonym.id == current_taxon.protonym.id
                                'return_to_original'
                              else
                                'secondary_junior_homonym'
                              end
    end

    render json: options.to_json(methods: [:authorship_string, :duplicate_type]), status: :ok
  end

  private
    def find_name_duplicates_only
      name_conflict_taxa = Taxon.where name_id: params[:new_parent_name_id]
      render json: name_conflict_taxa, status: :ok
    end

end
