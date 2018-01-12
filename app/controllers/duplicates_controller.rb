# Controller to handle the duplicates cases -
# cases where a species move from one genus to another - starting off in
# genus A, moving to genus B, and then back to A, while retaining the same
# species epithet.

class DuplicatesController < ApplicationController
  before_action :authenticate_editor

  # Takes requires parent_id (target parent) and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
  def find_duplicates
    # This check shouldn't be valid; there's nothing wrong with
    # a conflict in a subspecies parent, for example.
    # if @rank_to_create != "species"
    #   render nothing: true, status: :no_content
    #   return
    # end
    # TODO `params[:current_taxon_id]` is probably the same as `@taxon`
    # in `TaxaController`, which means we can use `set_taxon`.
    current_taxon = Taxon.find(params[:current_taxon_id])
    new_parent = Taxon.find_by(name_id: params[:new_parent_name_id])

    # Searching for genus / subspecies for conflict.
    options = if current_taxon.is_a? Subspecies
                new_parent.parent.find_subspecies_in_genus(current_taxon.name.epithet)
              else
                new_parent.find_epithet_in_genus(current_taxon.name.epithet)
              end
    head :no_content and return unless options

    # This code to pass these some other way, and remove these two columns from the taxa db entry
    options.each do |option|
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

    json = options.to_json methods: [:author_citation, :duplicate_type]
    render json: json, status: :ok
  end

  def find_name_duplicates_only
    name_conflict_taxa = Taxon.where name_id: params[:new_parent_name_id]
    render json: name_conflict_taxa, status: :ok
  end
end
