module Taxa
  class ConvertToSubspeciesController < ApplicationController
    before_action :ensure_can_edit_catalog
    before_action :set_taxon, only: [:new, :create]

    def new
    end

    # TODO move validations to service.
    def create
      unless @taxon.is_a? Species
        @taxon.errors.add :base,
          "Taxon to be converted to a subspecies must be of rank species."
        render :new and return
      end

      if @taxon.subspecies.present?
        @taxon.errors.add :base, <<-MSG
          This species has subspecies of its own,
          so it can't be converted to a subspecies
        MSG
        render :new and return
      end

      if params[:new_species_id].blank?
        @taxon.errors.add :base, 'Please select a species.'
        render :new and return
      end

      @new_species = Taxon.find(params[:new_species_id])

      unless @new_species.is_a? Species
        @taxon.errors.add :base, "The new parent must be of rank species."
        render :new and return
      end

      # TODO allow moving to incerae sedis genera
      unless @new_species.genus
        @taxon.errors.add :base, "The new parent must have a genus."
        render :new and return
      end

      unless @new_species.genus == @taxon.genus
        @taxon.errors.add :base, "The new parent must be in the same genus."
        render :new and return
      end

      new_subspecies = Taxa::ConvertToSubspecies[@taxon, @new_species]
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

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def create_activity original_species, new_subspecies
        original_species.create_activity :convert_species_to_subspecies,
          parameters: {
            original_species_id: original_species.id,
            name_was: original_species.name_html_cache,
            name: new_subspecies.name.name_html
          }
      end
  end
end
