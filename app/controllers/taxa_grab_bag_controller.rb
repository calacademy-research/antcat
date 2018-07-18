# Grab bag exracted from `TaxaController`. Not ideal, but having everything in
# `TaxaController` was very messy. Hopefully we can move everything here back
# to their home some day, or find a new place for them to live in.

class TaxaGrabBagController < ApplicationController
  before_action :authenticate_editor
  before_action :authenticate_superadmin, only: [:destroy, :confirm_before_delete]
  before_action :set_taxon

  # Return all the taxa that would be deleted if we delete this
  # particular ID, inclusive. Same as children, really.
  def confirm_before_delete
    @delete_impact_list = @taxon.delete_impact_list
    render "confirm_before_delete"
  end

  def destroy
    @taxon.delete_taxon_and_children
    redirect_to root_path, notice: "Taxon was successfully deleted."
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
    @taxon.elevate_to_species
    redirect_to catalog_path(@taxon), notice: "Subspecies was successfully elevated to a species."
  end

  # Show children on another page for performance reasons.
  # Example of a very slow page: http://localhost:3000/taxa/429244/edit
  def show_children
  end

  def reorder_history_items
    if @taxon.reorder_history_items params[:taxon_history_item]
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
end
