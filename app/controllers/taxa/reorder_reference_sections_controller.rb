# TODO: Copy-pasted into `Taxa::ReorderHistoryItemsController`.

module Taxa
  class ReorderReferenceSectionsController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon

    def create
      # NOTE: "reference_section_ids" would be better, but `params[:reference_section]` is what jQuery sends it as.
      if Taxa::Operations::ReorderReferenceSections[@taxon, params[:reference_section]]
        @taxon.create_activity :reorder_reference_sections, current_user
        render json: { success: true }
      else
        render json: @taxon.errors, status: :unprocessable_entity
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end
  end
end
