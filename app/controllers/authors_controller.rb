class AuthorsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: [:destroy]
  before_action :set_author, only: [:show, :destroy]

  def index
    @authors = Author.sorted_by_name.paginate(page: params[:page], per_page: 60).preload(:names)
  end

  def show
    @references = @author.references.order(:citation_year).includes(:document).paginate(page: params[:references_page])
    @taxa = @author.described_taxa.order("references.year, references.id").
      includes(:name, protonym: { authorship: :reference }).
      paginate(page: params[:taxa_page])
  end

  def destroy
    if @author.destroy
      @author.create_activity :destroy
      redirect_to authors_path, notice: 'Author was successfully deleted.'
    else
      redirect_to authors_path, alert: 'Could not delete author.'
    end
  end

  def autocomplete
    respond_to do |format|
      format.json do
        results = Autocomplete::AutocompleteAuthorNames[params[:term]]
        json = if params[:with_ids] # TODO: Start using this instead of just names as strings.
                 results.map { |name| { label: name.name, author_id: name.author_id } }
               else
                 results.map(&:name)
               end

        render json: json
      end
    end
  end

  private

    def set_author
      @author = Author.find(params[:id])
    end
end
