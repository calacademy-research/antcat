class JournalsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :set_journal, only: [:show, :edit, :update]

  def index
    @journals = Journal.order(:name)
    respond_to do |format|
      format.html
      format.json { render json: Journal.search(params[:term]) } # json search in #index
    end
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

  private
    def set_journal
      @journal = Journal.find(params[:id])
    end
    
    def journal_params
      params.require(:journal).permit(:name)
    end
end