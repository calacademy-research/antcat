# TODO: Remove once http://antcat.org/database_scripts/missing_references has been cleared.

module References
  class ReplaceMissingController < ApplicationController
    before_action :ensure_can_edit_catalog
    before_action :set_missing_reference
    before_action :set_target_reference, only: :create

    def show
      @table_refs = @missing_reference.what_links_here.paginate(page: params[:page], per_page: 100)
    end

    def create
      unless @target_reference
        redirect_to({ action: :new }, alert: "Target must be specified.")
        return
      end

      replace_missing!

      create_activity
      destroy_missing_reference

      redirect_to reference_path(@target_reference), notice: "Replaced the missing refenrece #{@missing_reference.keey}."
    end

    private

      def set_missing_reference
        @missing_reference = Reference.find(params[:id])
      end

      def set_target_reference
        @target_reference = Reference.find(params[:target_reference_id])
      end

      def replace_missing!
        References::ReplaceMissing[@missing_reference, @target_reference]
      end

      def create_activity
        @missing_reference.create_activity :replace_missing_reference, parameters: {
          citation: @missing_reference.citation,
          target_reference_id: @target_reference.id
        }
      end

      def destroy_missing_reference
        @missing_reference.destroy
        @missing_reference.create_activity :destroy
      end
  end
end
