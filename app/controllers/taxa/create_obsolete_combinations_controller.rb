module Taxa
  class CreateObsoleteCombinationsController < ApplicationController
    before_action :ensure_can_edit_catalog
    before_action :set_taxon
    before_action :set_obsolete_genus, only: :create

    def show
    end

    def create
      unless @obsolete_genus
        flash.now[:alert] = "Obsolete genus must be set."
        render :show
        return
      end

      obsolete_combination = create_obsolete_combination

      if obsolete_combination.persisted?
        create_activity obsolete_combination
        redirect_to catalog_path(obsolete_combination), notice: "Successfully created missing obsolete combination."
      else
        flash.now[:alert] = obsolete_combination.errors.full_messages.to_sentence
        render :show
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_obsolete_genus
        @obsolete_genus = Genus.find_by(id: params[:obsolete_genus_id])
      end

      def create_obsolete_combination
        Taxa::CreateObsoleteCombination[@taxon, @obsolete_genus]
      end

      def create_activity obsolete_combination
        obsolete_combination.create_activity :create_obsolete_combination
      end
  end
end
