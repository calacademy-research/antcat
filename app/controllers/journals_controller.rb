class JournalsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index, :show, :autocomplete]
  before_action :set_journal, only: [:show, :edit, :update, :destroy]

  def index
    order = params[:order] == "reference_count" ? "reference_count DESC" : :name

    @journals = Journal.includes_reference_count.order(order).
      paginate(page: params[:page], per_page: 100)
  end

  def show
    @references = @journal.references.
      order_by_author_names_and_year.
      includes_document.
      paginate(page: params[:page])
  end

  def new
    @journal = Journal.new
  end

  def edit
  end

  def create
    @journal = Journal.new journal_params
    if @journal.save
      @journal.create_activity :create
      redirect_to @journal, notice: "Successfully created journal."
    else
      render :new
    end
  end

  def update
    if @journal.update journal_params
      @journal.create_activity :update
      redirect_to @journal, notice: "Successfully updated journal."
    else
      render :edit
    end
  end

  def destroy
    if @journal.destroy
      @journal.create_activity :destroy
      redirect_to references_path, notice: "Journal was successfully deleted."
    else
      redirect_to @journal, alert: @journal.errors.full_messages.to_sentence
    end
  end

  def autocomplete
    search_query = params[:term] || '' # TODO standardize all "q/qq/query/term".

    respond_to do |format|
      format.json { render json: Autocomplete::AutocompleteJournals[search_query] }
    end
  end

  # For at.js. We need the IDs, which isn't included in `#autocomplete`.
  # TODO see if we can merge this with `#autocomplete`.
  def linkable_autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteLinkableJournals[search_query]
      end
    end
  end

  private

    def set_journal
      @journal = Journal.find(params[:id])
    end

    def journal_params
      params.require(:journal).permit(:name)
    end
end
