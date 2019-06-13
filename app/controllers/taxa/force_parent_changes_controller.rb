module Taxa
  class ForceParentChangesController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon
    before_action :set_valid_parent_ranks
    before_action :set_new_parent, only: [:create]

    def show
    end

    def create
      if @new_parent.blank? && !@taxon.is_a?(Genus)
        flash.now[:alert] = "A parent must be set."
        render :show
        return
      end

      if update_parent_and_save
        create_activity
        redirect_to catalog_path(@taxon), notice: "Successfully changed the parent."
      else
        flash.now[:alert] = "Something went wrong... ?"
        render :show
      end
    rescue Taxon::InvalidParent => e
      flash.now[:alert] = e.message
      render :show
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_valid_parent_ranks
        @valid_parent_ranks =
          case @taxon
          when Tribe      then [:subfamily]
          when Genus      then [:family, :subfamily, :tribe]
          when Subgenus   then [:genus]
          when Species    then [:genus, :subgenus]
          when Subspecies then [:species]
          end
      end

      def set_new_parent
        @new_parent = Taxon.find_by(id: params[:new_parent_id])
      end

      def update_parent_and_save
        Taxa::ForceParentChange[@taxon, @new_parent]
      end

      def create_activity
        @taxon.create_activity :force_parent_change
      end
  end
end
