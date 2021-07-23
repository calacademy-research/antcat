# frozen_string_literal: true

module Taxa
  class CreateObsoleteCombinationsController < ApplicationController
    before_action :ensure_user_is_editor

    def show
      @taxon = find_taxon
      @valid_parent_ranks = valid_parent_ranks
    end

    def create
      @taxon = find_taxon
      @obsolete_genus = find_obsolete_genus
      @valid_parent_ranks = valid_parent_ranks

      unless @obsolete_genus
        flash.now[:alert] = "Obsolete genus must be set."
        render :show
        return
      end

      obsolete_combination = Taxa::Operations::CreateObsoleteCombination[@taxon, @obsolete_genus]

      if obsolete_combination.persisted?
        create_activity obsolete_combination
        redirect_to catalog_path(obsolete_combination), notice: "Successfully created missing obsolete combination."
      else
        flash.now[:alert] = obsolete_combination.errors.full_messages.to_sentence
        render :show
      end
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end

      def find_obsolete_genus
        Genus.find_by(id: params[:obsolete_genus_id])
      end

      def valid_parent_ranks
        [Rank::GENUS]
      end

      def create_activity obsolete_combination
        obsolete_combination.create_activity Activity::CREATE_OBSOLETE_COMBINATION, current_user
      end
  end
end
