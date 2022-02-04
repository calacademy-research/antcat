# frozen_string_literal: true

module Taxa
  class ElevateToSpeciesController < ApplicationController
    before_action :ensure_user_is_editor

    def create
      @taxon = find_taxon

      unless @taxon.is_a?(Subspecies)
        redirect_to edit_taxon_path(@taxon), notice: "Not a subspecies"
        return
      end

      new_species = Taxa::Operations::ElevateToSpecies[@taxon]
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
    rescue Taxa::TaxonHasInfrasubspecies => e
      redirect_to catalog_path(@taxon), alert: e.message
    end

    private

      def find_taxon
        Taxon.find(params[:taxon_id])
      end

      def species_activity subspecies, new_species
        new_species.create_activity Activity::ELEVATE_SUBSPECIES_TO_SPECIES, current_user,
          parameters: {
            original_subspecies_id: subspecies.id,
            name_was: subspecies.name.name_html,
            name: new_species.name.name_html
          }
      end
  end
end
