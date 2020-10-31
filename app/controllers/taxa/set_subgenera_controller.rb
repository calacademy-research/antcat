# frozen_string_literal: true

module Taxa
  class SetSubgeneraController < ApplicationController
    before_action :ensure_user_is_editor

    def show
      @taxon = find_taxon
      @subgenus = find_subgenus @taxon
    end

    def create
      @taxon = find_taxon
      @subgenus = find_subgenus @taxon

      unless @subgenus
        redirect_to({ action: :show }, alert: "Subgenus must be specified.")
        return
      end

      if @taxon.update(subgenus: @subgenus)
        @taxon.create_activity Activity::SET_SUBGENUS, current_user, parameters: { set_subgenus_id_to: @subgenus.id }
        redirect_to catalog_path(@taxon), notice: "Successfully updated subgenus of species."
      else
        redirect_to({ action: :show }, alert: @taxon.errors.full_messages.to_sentence)
      end
    end

    def destroy
      taxon = find_taxon
      activity_parameters = { removed_subgenus_id: taxon.subgenus.id }

      if taxon.update(subgenus: nil)
        taxon.create_activity Activity::SET_SUBGENUS, current_user, parameters: activity_parameters
        redirect_to catalog_path(taxon), notice: "Successfully removed subgenus from species."
      else
        redirect_to({ action: :show }, alert: taxon.errors.full_messages.to_sentence)
      end
    end

    private

      def find_taxon
        Species.find(params[:taxa_id])
      end

      def find_subgenus taxon
        taxon.genus.subgenera.find_by(id: params[:subgenus_id])
      end
  end
end
