class IssuesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_issue, only: [:show, :edit, :update, :reopen, :close]

  def index
    @issues = Issue.by_status_and_date.includes(:adder).paginate(page: params[:page])
    @no_open_issues = !Issue.open.exists?
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
    @issue.create_activity :create, edit_summary: params[:edit_summary]

    if @issue.save
      redirect_to @issue, notice: "Successfully created issue."
    else
      render :new
    end
  end

  def update
    if @issue.update issue_params
      @issue.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render :edit
    end
  end

  def close
    @issue.close! current_user
    @issue.create_activity :close_issue

    redirect_to @issue, notice: "Successfully closed issue."
  end

  def reopen
    @issue.reopen!
    @issue.create_activity :reopen_issue

    redirect_to @issue, notice: "Successfully re-opened issue."
  end

  private

    def set_issue
      @issue = Issue.find params[:id]
    end

    def issue_params
      params.require(:issue).permit :title, :description
    end
end
