module Taxa
  class ElevateToSpeciesController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon

    def create
      unless @taxon.is_a? Subspecies
        redirect_to edit_taxa_path(@taxon), notice: "Not a subspecies"
        return
      end

      new_species = Taxa::ElevateToSpecies[@taxon]
      if new_species.persisted?
        species_activity @taxon, new_species
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

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def species_activity subspecies, new_species
        new_species.create_activity :elevate_subspecies_to_species,
          parameters: {
            original_subspecies_id: subspecies.id,
            name_was: subspecies.name_html_cache,
            name: new_species.name.name_html
          }
      end
  end
end
