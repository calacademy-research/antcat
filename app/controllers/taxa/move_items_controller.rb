# frozen_string_literal: true

module Taxa
  class MoveItemsController < ApplicationController
    before_action :ensure_user_is_editor

    def new
      @taxon = find_taxon
    end

    def show
      @taxon = find_taxon
      @to_taxon = find_to_taxon

      unless @to_taxon
        redirect_to({ action: :new }, alert: "Target must be specified.")
      end
    end

    def create
      @taxon = find_taxon
      @to_taxon = find_to_taxon

      if reference_sections.empty?
        flash.now[:alert] = "At least one item must be selected."
        render :show
        return
      end

      if Taxa::Operations::MoveItems[@to_taxon, reference_sections: reference_sections]
        @taxon.create_activity Activity::MOVE_ITEMS, current_user, parameters: { to_taxon_id: @to_taxon.id }
        redirect_to taxa_move_items_path(@taxon, to_taxon_id: @to_taxon.id),
          notice: "Successfully moved items. Items can be re-ordered at the taxon's edit page."
      else
        flash.now[:alert] = "Something went wrong... ?"
        render :show
      end
    rescue Taxa::Operations::MoveItems::ReferenceSectionsNotSupportedForRank
      flash.now[:alert] = "Rank of target does not support reference sections."
      render :show
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end

      def find_to_taxon
        Taxon.find_by(id: params[:to_taxon_id])
      end

      def reference_sections
        @_reference_sections ||= ReferenceSection.where(id: params[:reference_section_ids]).order(:position)
      end
  end
end
