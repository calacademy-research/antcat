# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index, :show]

  def index
    @issues = Issue.by_status_and_date.includes(:adder).paginate(page: params[:page])
    @no_open_issues = !Issue.open.exists?
  end

  def show
    @issue = find_issue
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
      Users::NotifyMentionedUsers[@issue.description, attached: @issue, notifier: current_user]
      redirect_to @issue, notice: "Successfully created issue."
    else
      render :new
    end
  end

  def edit
    @issue = find_issue
  end

  def update
    @issue = find_issue

    if @issue.update(issue_params)
      @issue.create_activity :update, current_user, edit_summary: params[:edit_summary]
      Users::NotifyMentionedUsers[@issue.description, attached: @issue, notifier: current_user]
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render :edit
    end
  end

  def close
    issue = find_issue

    issue.close! current_user
    issue.create_activity :close_issue, current_user

    redirect_to issue, notice: "Successfully closed issue."
  end

  def reopen
    issue = find_issue

    issue.reopen!
    issue.create_activity :reopen_issue, current_user

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
