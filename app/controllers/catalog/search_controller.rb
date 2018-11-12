module Catalog
  class SearchController < ApplicationController
    DEFAULT_PER_PAGE = 30

    before_action :antweb_legacy_route, only: [:index]

    # This is the "Advanced Search" page.
    def index
      return if not_searching_yet? # Just render the form.

      @taxa = Taxa::AdvancedSearch[advanced_search_params]
      @is_author_search = is_author_search?

      respond_to do |format|
        format.html do
          @taxa = @taxa.paginate page: params[:page],
            per_page: (params[:per_page] || DEFAULT_PER_PAGE)
        end

        format.text do
          text = @taxa.reduce('') do |content, taxon|
                   content << AdvancedSearchPresenter::Text.new.format(taxon)
                 end
          send_data text, filename: download_filename, type: 'text/plain'
        end
      end
    end

    # The "quick search" shares the same view as the "Advanced Search".
    # The forms could be merged, but having two is pretty nice too.
    def quick_search
      if searching_for_nothing_from_the_header?
        redirect_to action: :index
        return
      end

      taxa = Taxa::QuickSearch[
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
      def not_searching_yet?
        params[:rank].blank?
      end

      def searching_for_nothing_from_the_header?
        params[:qq].blank? && params[:im_feeling_lucky].present?
      end

      def advanced_search_params
        params.slice :author_name, :rank, :year, :name, :locality, :valid_only,
          :biogeographic_region, :genus, :forms, :type_information, :status, :fossil,
          :nomen_nudum, :unresolved_junior_homonym, :ichnotaxon, :hong
      end

      def is_author_search?
        params[:author_name].present? && no_matching_authors?(params[:author_name])
      end

      def no_matching_authors? name
        AuthorName.find_by(name: name).nil?
      end

      def single_match_we_should_redirect_to? taxa
        params[:im_feeling_lucky] && taxa.count == 1
      end

      def download_filename
        "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
      end
  end
end
