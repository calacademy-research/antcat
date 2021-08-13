# frozen_string_literal: true

module Taxa
  class ForceUpdatesController < ApplicationController
    before_action :ensure_user_is_superadmin

    def show
      @taxon = find_taxon
    end

    def update
      @taxon = find_taxon

      @taxon.attributes = taxon_params

      if edit_summary.blank?
        flash.now[:error] = "An edit summary is required for this change."
        render :show
        return
      end

      if @taxon.save
        @taxon.create_activity Activity::FORCE_UPDATE_DATABASE_RECORD, current_user, edit_summary: edit_summary
        redirect_to catalog_path(@taxon), notice: "Successfully force-updated database record."
      else
        render :show
      end
    end

    private

      def find_taxon
        Taxon.find(params[:taxon_id])
      end

      def taxon_params
        params.require(:taxon).permit(
          :status,
          :incertae_sedis_in,
          :family_id,
          :subfamily_id,
          :tribe_id,
          :genus_id,
          :subgenus_id,
          :species_id,
          :subspecies_id,
          :current_taxon_id,
          :homonym_replaced_by_id
        )
      end

      def edit_summary
        params[:edit_summary]
      end
  end
end
