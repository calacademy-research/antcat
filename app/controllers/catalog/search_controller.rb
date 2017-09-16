module Catalog
  class SearchController < ApplicationController
    DEFAULT_PER_PAGE = 30

    before_action :antweb_legacy_route, only: [:index]

    # This is the "Advanced Search" page.
    def index
      return if user_not_searching_yet? # Just render the form.

      @taxa = Taxa::AdvancedSearch[advanced_search_params]
      @is_author_search = is_author_search?

      respond_to do |format|
        format.html do
          @taxa = @taxa.paginate page: params[:page],
            per_page: (params[:per_page] || DEFAULT_PER_PAGE)
        end

        format.text do
          text = Exporters::AdvancedSearchExporter[@taxa]
          send_data text, filename: download_filename, type: 'text/plain'
        end
      end
    end

    # The "quick search" shares the same view as the "Advanced Search".
    # The forms could be merged, but having two is pretty nice too.
    def quick_search
      taxa = taxa = Taxa::QuickSearch[
        params[:qq],
        search_type: params[:search_type],
        valid_only: params[:valid_only]
      ]

      if single_match_we_should_redirect_to? taxa
        return redirect_to catalog_path(taxa.first, qq: params[:qq])
      end

      @taxa = taxa.paginate page: params[:page],
        per_page: (params[:per_page] || DEFAULT_PER_PAGE)

      @is_quick_search = true
      render "index"
    end

    private
      # AntWeb's "View in AntCat" links are hardcoded to use the now
      # deprecated param "st" (starts_with). Links look like this:
      # http://www.antcat.org/catalog/search?st=m&qq=Agroecomyrmecinae&commit=Go
      # (from https://www.antweb.org/images.do?subfamily=agroecomyrmecinae)
      def antweb_legacy_route
        if params[:st].present? && params[:qq].present?
          redirect_to catalog_quick_search_path(qq: params[:qq], im_feeling_lucky: true)
        end
      end

      # A blank `params[:rank]` means the user has not made a search yet.
      def user_not_searching_yet?
        params[:rank].blank?
      end

      def advanced_search_params
        params.slice :author_name, :rank, :year, :name, :locality, :valid_only,
          :verbatim_type_locality, :type_specimen_repository, :type_specimen_code,
          :biogeographic_region, :genus, :forms
      end

      def is_author_search?
        params[:author_name].present? && no_matching_authors?(params[:author_name])
      end

      def no_matching_authors? name
        AuthorName.find_by(name: name).nil?
      end

      # If user searched from the search box in the header, and
      # theres a single match, then redirect to that match.
      #
      # "im_feeling_lucky" is manually set in the header search forms,
      # so we know when to redirect (the forms on the seach page never redirects,
      # because that would be annoying).
      def single_match_we_should_redirect_to? taxa
        params[:im_feeling_lucky] && taxa.count == 1
      end

      def download_filename
        "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
      end
  end
end
