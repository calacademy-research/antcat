class DuplicatesController < ApplicationController
  before_action :ensure_can_edit_catalog

  # Takes requires parent_id (target parent) and previous_combination_id
  # returns all matching taxa that could conflict with this naming.
  def find_duplicates
    current_taxon = Taxon.find(params[:current_taxon_id])
    new_parent = Taxon.find_by(name_id: params[:new_parent_name_id])

    # Searching for genus / subspecies for conflict.
    options = if current_taxon.is_a? Subspecies
                new_parent.parent.find_subspecies_in_genus(current_taxon.name.epithet)
              else
                new_parent.find_epithet_in_genus(current_taxon.name.epithet)
              end
    head :no_content and return unless options

    options.each do |option|
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
