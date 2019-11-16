class IssuesController < ApplicationController
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index, :show]
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

  def create
    @issue = Issue.new(issue_params)
    @issue.adder = current_user

    if @issue.save
      @issue.create_activity :create, current_user, edit_summary: params[:edit_summary]
      @issue.notify_users_mentioned_in @issue.description, notifier: current_user
      redirect_to @issue, notice: "Successfully created issue."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @issue.update(issue_params)
      @issue.create_activity :update, current_user, edit_summary: params[:edit_summary]
      @issue.notify_users_mentioned_in @issue.description, notifier: current_user
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render :edit
    end
  end

  def close
    @issue.close! current_user
    @issue.create_activity :close_issue, current_user

    redirect_to @issue, notice: "Successfully closed issue."
  end

  def reopen
    @issue.reopen!
    @issue.create_activity :reopen_issue, current_user

    redirect_to @issue, notice: "Successfully re-opened issue."
  end

  private

    def set_issue
      @issue = Issue.find(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:title, :description)
    end
end
