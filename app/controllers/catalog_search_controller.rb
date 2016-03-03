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
