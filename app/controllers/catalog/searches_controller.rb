# frozen_string_literal: true

module Catalog
  class SearchesController < ApplicationController
    PER_PAGE_OPTIONS = [30, 100, 500, 1000]
    SEARCHING_FROM_HEADER = "searching_from_header"

    def show
      return if not_searching_yet? || searching_for_nothing_from_header? # Just render the form.

      if redirect_if_single_exact_match? && (single_match = Catalog::Search::SingleMatchToRedirectTo[params[:qq]])
        return redirect_to catalog_path(single_match, qq: params[:qq]), notice: <<~MSG
          You were redirected to an exact match. <a href='/catalog/search?qq=#{params[:qq]}'>Show more results.</a>
        MSG
      end

      if searching_for_non_existent_author?
        flash.now[:alert] = "If you're choosing an author, make sure you pick the name from the dropdown list."
        return
      end

      # TODO: Hmm.
      if params[:qq].present?
        params[:name] = params[:qq]
      end

      @taxa = Catalog::AdvancedSearchQuery[advanced_search_params]

      respond_to do |format|
        format.html do
          @taxa = @taxa.paginate(page: params[:page], per_page: params[:per_page])
        end

        format.text do
          send_data Exporters::Taxa::TaxaAsTxt[@taxa], filename: download_filename, type: 'text/plain'
        end
      end
    end

    private

      def advanced_search_params
        params.slice(
          :author_name,
          :biogeographic_region,
          :collective_group_name,
          :epithet,
          :forms,
          :fossil,
          :genus,
          :hong,
          :ichnotaxon,
          :incertae_sedis_in,
          :locality,
          :must_have_history_items,
          :name,
          :name_search_type,
          :nomen_nudum,
          :protonym,
          :status,
          :type,
          :type_information,
          :unresolved_homonym,
          :valid_only,
          :year
        )
      end

      def per_page
        params[:per_page] if params[:per_page].to_i <= PER_PAGE_OPTIONS.max
      end

      def not_searching_yet?
        params.except(:controller, :action).blank?
      end

      def searching_for_nothing_from_header?
        params[:qq].blank? && searching_from_header?
      end

      def searching_for_non_existent_author?
        return false if params[:author_name].blank?
        !AuthorName.where(name: params[:author_name]).exists?
      end

      def redirect_if_single_exact_match?
        searching_from_header? || antweb_legacy_route?
      end

      def searching_from_header?
        params[SEARCHING_FROM_HEADER].present?
      end

      # AntWeb's "View in AntCat" links are hardcoded to use the now
      # deprecated param "st" (starts_with). Links look like this:
      # http://www.antcat.org/catalog/search?st=m&qq=Agroecomyrmecinae&commit=Go
      # (from https://www.antweb.org/images.do?subfamily=agroecomyrmecinae)
      def antweb_legacy_route?
        params[:st].present? && params[:qq].present?
      end

      def download_filename
        "antcat_search_results__#{Time.current.strftime('%Y-%m-%d__%H_%M_%S')}.txt"
      end
  end
end
