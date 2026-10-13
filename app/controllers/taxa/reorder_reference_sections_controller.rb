# frozen_string_literal: true

module Taxa
  class ReorderReferenceSectionsController < ApplicationController
    before_action :ensure_user_is_editor

    def show
      @taxon = find_taxon
    end

    def create
      @taxon = find_taxon

      if Taxa::Operations::ReorderReferenceSections[@taxon, new_order]
        @taxon.create_activity :reorder_reference_sections, current_user
        redirect_to taxon_reorder_reference_sections_path(@taxon), notice: 'Reference sections were successfully reordered.'
      else
        flash.now[:alert] = @taxon.errors.full_messages.to_sentence
        render :show, status: :unprocessable_content
      end
    end

    private

      def find_taxon
        Taxon.find(params.expect(:taxon_id))
      end

      def new_order
        # The form sends `new_order=""` when there is nothing to reorder; `expect` would reject that with 400.
        params[:new_order].split(',') # rubocop:disable Rails/StrongParametersExpect
      end
  end
end
