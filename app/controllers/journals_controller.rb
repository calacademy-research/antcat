class JournalsController < ApplicationController
  REFERENCE_COUNT_ORDER = "reference_count"

  before_action :ensure_user_is_at_least_helper, except: [:index, :show, :autocomplete]
  before_action :set_journal, only: [:show, :edit, :update, :destroy]

  def index
    order = params[:order] == REFERENCE_COUNT_ORDER ? "reference_count DESC" : :name
    @journals = Journal.includes_reference_count.order(order).paginate(page: params[:page], per_page: 100)
  end

  def show
    @references = @journal.references.order(:year).includes(:document).paginate(page: params[:page])
  end

  def edit
  end

  def update
    if @journal.update(journal_params)
      @journal.create_activity :update
      @journal.invalidate_reference_caches!
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
    search_query = params[:term] || '' # TODO: Standardize all "q/qq/query/term".

    respond_to do |format|
      format.json { render json: Autocomplete::AutocompleteJournals[search_query] }
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
