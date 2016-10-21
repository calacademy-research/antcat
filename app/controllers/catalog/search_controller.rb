module Catalog
  class SearchController < ApplicationController
    before_action :antweb_legacy_route, only: [:index]

    def index
      # A blank params[:rank] means the user has not searched yet,
      # so just render the form.
      return unless params[:rank].present?

      @taxa = advanced_search_taxa
      @is_author_search = is_author_search?

      respond_to do |format|
        format.html do
          @taxa = @taxa.paginate(page: params[:page])
        end

        format.text do
          text = Exporters::AdvancedSearchExporter.new.export @taxa
          send_data text, filename: download_filename, type: 'text/plain'
        end
      end
    end

    def quick_search
      taxa = Taxa::Search.find_name(params[:qq], params[:search_type])
      taxa = taxa.valid if params[:valid_only]

      # Single match --> redirect
      if params[:im_feeling_lucky] && taxa.count == 1
        return redirect_to catalog_path(taxa.first, qq: params[:qq])
      end

      @taxa = taxa.paginate(page: params[:page])

      @is_quick_search = true
      render "index"
    end

    private
      def antweb_legacy_route
        # "st" (starts_with) is not used any longer, so use it to find legacy URLs
        if params[:st].present? && params[:qq].present?
          redirect_to catalog_quick_search_path(qq: params[:qq], im_feeling_lucky: true)
        end
      end

      def advanced_search_taxa
        Taxa::Search.advanced_search(
          author_name:              params[:author_name],
          rank:                     params[:rank],
          year:                     params[:year],
          name:                     params[:name],
          locality:                 params[:locality],
          valid_only:               params[:valid_only],
          verbatim_type_locality:   params[:verbatim_type_locality],
          type_specimen_repository: params[:type_specimen_repository],
          type_specimen_code:       params[:type_specimen_code],
          biogeographic_region:     params[:biogeographic_region],
          genus:                    params[:genus],
          forms:                    params[:forms])
      end

      def is_author_search?
        params[:author_name].present? && no_matching_authors?(params[:author_name])
      end

      def no_matching_authors? name
        AuthorName.find_by_name(name).nil?
      end

      def download_filename
        "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
      end
  end
end
