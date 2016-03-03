class CatalogSearchController < ApplicationController
  def show
    return unless params[:rank].present? # just render the template

    @taxa = get_taxa
    @is_author_search = is_author_search?
    @filename = filename

    respond_to do |format|
      format.html do
        @taxa = @taxa.paginate(page: params[:page])
      end

      format.text do
        text = Exporters::AdvancedSearchExporter.new.export @taxa
        send_data text, filename: @filename, type: 'text/plain'
      end
    end
  end

  def quick_search
    @is_quick_search = true
    @taxa = Taxa::Search.find_name(params[:qq], params[:search_type])
      .paginate(page: params[:page])

    # Single match --> skip search results and just show the match
    if params[:im_feeling_lucky] && @taxa && @taxa.count == 1
      return redirect_to catalog_path(@taxa.first, qq: params[:qq])
    end

    render "show"
  end

  private
    def get_taxa
      Taxa::Search.advanced_search(
        author_name:              params[:author_name],
        rank:                     params[:rank],
        year:                     params[:year],
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

    def filename
      "#{params[:author_name]}-#{params[:rank]}-#{params[:year]}-#{params[:locality]}-#{params[:valid_only]}".parameterize + '.txt'
    end
end
