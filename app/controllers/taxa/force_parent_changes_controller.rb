module Taxa
  class ForceParentChangesController < ApplicationController
    before_action :authenticate_superadmin
    before_action :set_taxon
    before_action :set_new_parent, only: [:create]

    def show
    end

    def create
      unless @new_parent
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
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_new_parent
        @new_parent = Taxon.find_by(id: params[:new_parent_id])
      end

      def update_parent_and_save
        @taxon.transaction do
          @taxon.update_parent @new_parent
          @taxon.save
        end
      end

      def create_activity
        @taxon.create_activity :force_parent_change
      end
  end
end
