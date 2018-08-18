class IssuesController < ApplicationController
  before_action :ensure_can_edit_catalog, except: [:index, :show]
  before_action :set_issue, only: [:show, :edit, :update, :reopen, :close]

  def index
    @issues = Issue.by_status_and_date.paginate(page: params[:page])
    @open_issues_count = Issue.open.count
  end

  def show
    @new_comment = Comment.build_comment @issue, current_user
  end

  def new
    @issue = Issue.new
  end

  def edit
  end

  def create
    @issue = Issue.new issue_params
    @issue.adder = current_user

    if @issue.save
      redirect_to @issue, notice: "Successfully created issue."
    else
      render :new
    end
  end

  def update
    if @issue.update issue_params
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render :edit
    end
  end

  def close
    @issue.close! current_user

    redirect_to @issue, notice: "Successfully closed issue."
  end

  def reopen
    @issue.reopen!

    redirect_to @issue, notice: "Successfully re-opened issue."
  end

  def autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteIssues[search_query]
      end
    end
  end

  private

    def set_issue
      @issue = Issue.find params[:id]
    end

    def issue_params
      params.require(:issue).permit :title, :description
    end
end
