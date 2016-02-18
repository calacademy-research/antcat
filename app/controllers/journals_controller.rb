class JournalsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :autocomplete]
  before_filter :set_journal, only: [:show, :edit, :update]
  layout "references"

  def index
    @journals = Journal.order(:name).paginate(page: params[:page], per_page: 100)
  end

  def show
    @references = Reference.sorted_by_principal_author_last_name.where(journal: @journal)
  end

  def new
    @journal = Journal.new
  end

  def edit
  end

  def create
    @journal = Journal.new journal_params
    if @journal.save
      flash[:notice] = "Successfully created journal."
      redirect_to @journal
    else
      render :new
    end
  end

  def update
    if @journal.update journal_params
      flash[:notice] = "Successfully updated journal."
      redirect_to @journal
    else
      render :edit
    end
  end

  def autocomplete
    respond_to do |format|
      format.json { render json: Journal.search(params[:term]) }
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