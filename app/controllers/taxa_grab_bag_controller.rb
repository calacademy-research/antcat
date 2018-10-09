# Grab bag exracted from `TaxaController`. Not ideal, but having everything in
# `TaxaController` was very messy. Hopefully we can move everything here back
# to their home some day, or find a new place for them to live in.

class TaxaGrabBagController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :authenticate_superadmin, only: [:destroy, :confirm_before_delete]
  before_action :set_taxon

  # Return all the taxa that would be deleted if we delete this
  # particular ID, inclusive. Same as children, really.
  def confirm_before_delete
    @delete_impact_list = Taxa::DeleteImpactList[@taxon]
    render "confirm_before_delete"
  end

  def destroy
    Taxa::DeleteTaxonAndChildren[@taxon]
    redirect_to root_path, notice: "Taxon was successfully deleted."
  rescue ActiveRecord::StatementInvalid => e
    redirect_to confirm_before_delete_taxa_path(@taxon), alert: "error: #{e}"
  end

  # "Light version" of `#destroy` (which is for superadmins only). A button to this
  # method is shown when there are no non-taxt references to the current taxon.
  def destroy_unreferenced
    references = @taxon.what_links_here
    if references.empty?
      @taxon.destroy
    else
      redirect_to edit_taxa_path(@taxon), notice: <<-MSG.squish
        Other taxa refer to this taxon, so it can't be deleted.
        Please talk to Stan (sblum@calacademy.org) to determine a solution.
        The items referring to this taxon are: #{references}.
      MSG
      return
    end
    redirect_to catalog_path(@taxon.parent), notice: "Taxon was successfully deleted."
  end

  def elevate_to_species
    unless @taxon.is_a? Subspecies
      redirect_to edit_taxa_path(@taxon), notice: "Not a subspecies"
      return
    end

    new_species = Taxa::ElevateToSpecies[@taxon]
    if new_species.persisted?
      create_elevate_to_species_activity @taxon, new_species
      redirect_to catalog_path(new_species), notice: <<~MSG
        <p>Subspecies was successfully elevated to a species.<p>

        <p>The old subspecies record has not been modified and must be manually updated.</p>

        <p>
          What to do:<br>
          • The status of the old subspecies should probably be "obsolete combination"<br>
          • See if synonyms must be moved (must be manually moved)<br>
          • Check 'What link here'
        </p>
      MSG
    else
      # This case may not be possible as of writing, but once we add more validations it may be.
      redirect_to catalog_path(@taxon), alert: new_species.errors.full_messages.to_sentence
    end
  end

  # Show children on another page for performance reasons.
  # Example of a very slow page: http://localhost:3000/taxa/429244/edit
  def show_children
  end

  def reorder_history_items
    if Taxa::ReorderHistoryItems[@taxon, params[:taxon_history_item]]
      render json: { success: true }
    else
      render json: @taxon.errors, status: :unprocessable_entity
    end
  end

  # TODO move logic to model?
  def update_parent
    new_parent = Taxon.find params[:new_parent_id]
    case new_parent
    when Species   then @taxon.species = new_parent
    when Genus     then @taxon.genus = new_parent
    when Subgenus  then @taxon.subgenus = new_parent
    when Subfamily then @taxon.subfamily = new_parent
    when Family    then @taxon.family = new_parent
    end

    @taxon.save!
    redirect_to edit_taxa_path(@taxon)
  end

  private

    def set_taxon
      @taxon = Taxon.find params[:id]
    end

    def create_elevate_to_species_activity subspecies, new_species
      subspecies.create_activity :elevate_subspecies_to_species,
        parameters: {
          original_subspecies_id: subspecies.id,
          name_was: subspecies.name_html_cache,
          name: new_species.name.name_html
        }
    end
end
