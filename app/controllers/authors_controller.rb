class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  def index
    @authors = Author.sorted_by_name.
      paginate(page: params[:page], per_page: 60).
      preload(:names)
  end

  def show
    @references = @author.references.order(:citation_year).includes_document.paginate(page: params[:references_page])
    @taxa = @author.described_taxa.order("references.year, references.id").
      includes(:name, protonym: { authorship: :reference }).
      paginate(page: params[:taxa_page])
  end

  def autocomplete
    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteAuthorNames[params[:term]]
      end
    end
  end

  private

    def set_author
      @author = Author.find params[:id]
    end
end
