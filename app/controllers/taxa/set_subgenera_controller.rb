module Taxa
  class SetSubgeneraController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon
    before_action :set_subgenus, only: [:show, :create]

    def show
    end

    def create
      unless @subgenus
        redirect_to({ action: :show }, alert: "Subgenus must be specified.")
        return
      end

      if @taxon.update(subgenus: @subgenus)
        @taxon.create_activity :set_subgenus, current_user, parameters: { set_subgenus_id_to: @subgenus.id }
        redirect_to catalog_path(@taxon), notice: "Successfully updated subgenus of species."
      else
        redirect_to({ action: :show }, alert: @taxon.errors.full_messages.to_sentence)
      end
    end

    def destroy
      activity_parameters = { removed_subgenus_id: @taxon.subgenus.id }

      if @taxon.update(subgenus: nil)
        @taxon.create_activity :set_subgenus, current_user, parameters: activity_parameters
        redirect_to catalog_path(@taxon), notice: "Successfully removed subgenus from species."
      else
        redirect_to({ action: :show }, alert: @taxon.errors.full_messages.to_sentence)
      end
    end

    private

      def set_taxon
        @taxon = Species.find(params[:taxa_id])
      end

      def set_subgenus
        @subgenus = @taxon.genus.subgenera.find_by(id: params[:subgenus_id])
      end
  end
end
