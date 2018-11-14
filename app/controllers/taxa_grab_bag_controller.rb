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

  # Show children on another page for performance reasons.
  # Example of a very slow page: http://localhost:3000/taxa/429244/edit
  def show_children
  end

  private

    def set_taxon
      @taxon = Taxon.find params[:id]
    end
end
