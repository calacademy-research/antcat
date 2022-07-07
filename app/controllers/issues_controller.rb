# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index, :show]
  before_action :ensure_user_is_superadmin, only: [:destroy]

  def index
    @issues = Issue.by_status_and_date.includes(:user).paginate(page: params[:page])
    @no_open_issues = !Issue.open.exists?
    @recent_activities = Activity.issue_activities.most_recent_first.limit(5).includes(:user)
  end

  def show
    @issue = find_issue
    @new_comment = Comment.build_comment(@issue, current_user)
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(issue_params)
    @issue.user = current_user

    if @issue.save
      @issue.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      Notifications::NotifyMentionedUsers[@issue.description, attached: @issue, notifier: current_user]
      redirect_to @issue, notice: "Successfully created issue."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @issue = find_issue
  end

  def update
    @issue = find_issue

    if @issue.update(issue_params)
      @issue.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      Notifications::NotifyMentionedUsers[@issue.description, attached: @issue, notifier: current_user]
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    issue = find_issue

    issue.destroy!
    issue.create_activity Activity::DESTROY, current_user

    redirect_to issues_path, notice: "Issue was successfully deleted."
  end

  def close
    issue = find_issue

    issue.close! current_user
    issue.create_activity Activity::CLOSE_ISSUE, current_user

    redirect_to issue, notice: "Successfully closed issue."
  end

  def reopen
    issue = find_issue

    issue.reopen!
    issue.create_activity Activity::REOPEN_ISSUE, current_user

    redirect_to issue, notice: "Successfully re-opened issue."
  end

  private

    def find_issue
      Issue.find(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:description, :help_wanted, :title)
    end
end
