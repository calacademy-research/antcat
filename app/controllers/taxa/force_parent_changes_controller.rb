# frozen_string_literal: true

module Taxa
  class ForceParentChangesController < ApplicationController
    before_action :ensure_user_is_editor

    def show
      @taxon = find_taxon
      @valid_parent_ranks = valid_parent_ranks @taxon
    end

    def create
      @taxon = find_taxon
      @valid_parent_ranks = valid_parent_ranks @taxon
      @new_parent = find_new_parent

      if @new_parent.nil? && !@taxon.is_a?(Genus)
        flash.now[:alert] = "A parent must be set."
        render :show
        return
      end

      if Taxa::Operations::ForceParentChange[@taxon, @new_parent]
        create_activity @taxon
        redirect_to catalog_path(@taxon), notice: "Successfully changed the parent."
      else
        flash.now[:alert] = "Something went wrong... ?"
        render :show
      end
    rescue Taxa::InvalidParent, Taxa::TaxonHasSubspecies, Taxa::TaxonHasInfrasubspecies => e
      flash.now[:alert] = e.message
      render :show
    rescue Taxa::TaxonExists => e
      name_links = e.names.map { |name| view_context.link_to(name.name_html, name_path(name)) }
      flash.now[:alert] = "Name conflict: #{name_links.join}"
      render :show
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end

      def valid_parent_ranks taxon
        case taxon
        when ::Tribe      then [Rank::SUBFAMILY]
        when ::Genus      then [Rank::FAMILY, Rank::SUBFAMILY, Rank::TRIBE]
        when ::Subgenus   then [Rank::GENUS]
        when ::Species    then [Rank::GENUS, Rank::SUBGENUS]
        when ::Subspecies then [Rank::SPECIES]
        end
      end

      def find_new_parent
        Taxon.find_by(id: params[:new_parent_id])
      end

      def create_activity taxon
        taxon.create_activity Activity::FORCE_PARENT_CHANGE, current_user
      end
  end
end
