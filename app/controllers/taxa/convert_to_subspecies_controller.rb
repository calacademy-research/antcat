# frozen_string_literal: true

module Taxa
  class ConvertToSubspeciesController < ApplicationController
    before_action :ensure_user_is_editor

    def new
      @taxon = find_taxon
      @convert_to_subspecies_policy = ConvertToSubspeciesPolicy.new(@taxon)
    end

    # TODO: Move validations to service.
    def create
      @taxon = find_taxon
      @new_species = find_new_species
      @convert_to_subspecies_policy = ConvertToSubspeciesPolicy.new(@taxon)

      unless @new_species.is_a?(Species)
        @taxon.errors.add :base, 'Please select a species.'
        render :new
        return
      end

      if @taxon.subspecies.present?
        @taxon.errors.add :base, "Species with subspecies of its own cannot be converted to subspecies"
        render :new
        return
      end

      unless @new_species.genus == @taxon.genus
        @taxon.errors.add :base, "The new parent must be in the same genus."
        render :new
        return
      end

      new_subspecies = Taxa::Operations::ConvertToSubspecies[@taxon, @new_species]
      if new_subspecies.persisted?
        create_activity @taxon, new_subspecies
        redirect_to catalog_path(new_subspecies), notice: <<~MSG
          <p>Species was successfully converted to a subspecies.<p>

          <p>The old species record has not been modified and must be manually updated.</p>

          <p>
            What to do:<br>
            • The status of the old species should probably be "obsolete combination"<br>
            • See if synonyms must be moved (must be manually moved)<br>
            • Check 'What link here'
          </p>
        MSG
      else
        # This case may not be possible as of writing, but once we add more validations it may be.
        redirect_to catalog_path(@taxon), alert: new_subspecies.errors.full_messages.to_sentence
      end
    end

    private

      def find_taxon
        Species.find(params[:taxon_id])
      end

      def find_new_species
        Taxon.find_by(id: params[:new_species_id])
      end

      def create_activity original_species, new_subspecies
        new_subspecies.create_activity Activity::CONVERT_SPECIES_TO_SUBSPECIES, current_user,
          parameters: {
            original_species_id: original_species.id,
            name_was: original_species.name.name_html,
            name: new_subspecies.name.name_html
          }
      end
  end
end
