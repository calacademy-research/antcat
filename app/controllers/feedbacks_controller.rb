# frozen_string_literal: true

class FeedbacksController < ApplicationController
  BANNED_IPS = ["46.161.9.20", "46.161.9.51", "46.161.9.22"]

  before_action :ensure_user_is_at_least_helper, except: [:new, :create]
  before_action :ensure_user_is_superadmin, only: [:destroy]

  invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

  def index
    @feedbacks = Feedback.by_status_and_date.includes(:user).paginate(page: params[:page], per_page: 10)
  end

  def show
    @feedback = find_feedback
    @new_comment = Comment.build_comment @feedback, current_user
  end

  def new
    @feedback = Feedback.new(page: params[:page])
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.ip = request.remote_ip

    if ip_banned? || rate_throttle?
      @feedback.errors.add :base, <<~MSG
        You have already posted a couple of feedbacks in the last few minutes. Thanks for that!
        Please wait for a few minutes while we are trying to figure out if you are a bot...
      MSG
      render :new
      return
    end

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    if @feedback.save
      @feedback.create_activity :create, current_user
      redirect_to root_path, notice: <<~MSG
        Message sent (feedback id #{@feedback.id}). Thanks for helping us make AntCat better!
      MSG
    else
      render :new
    end
  end

  def edit
    @feedback = find_feedback
  end

  def update
    @feedback = find_feedback

    if @feedback.update(feedback_params)
      @feedback.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @feedback, notice: "Successfully updated feedback."
    else
      render :edit
    end
  end

  def destroy
    feedback = find_feedback

    feedback.destroy!
    feedback.create_activity :destroy, current_user

    redirect_to feedbacks_path, notice: "Feedback item was successfully deleted."
  end

  def close
    feedback = find_feedback

    feedback.close!
    feedback.create_activity :close_feedback, current_user

    redirect_to feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    feedback = find_feedback

    feedback.reopen!
    feedback.create_activity :reopen_feedback, current_user

    redirect_to feedback, notice: "Successfully re-opened feedback item."
  end

  private

    def find_feedback
      Feedback.find(params[:id])
    end

    def feedback_params
      params.require(:feedback).permit(:comment, :name, :email, :user, :page)
    end

    def on_spam _options = {}
      redirect_to root_path "You're not a bot are you? Feedback not sent. Email us?"
    end

    def ip_banned?
      request.remote_ip.in? BANNED_IPS
    end

    def rate_throttle?
      return if current_user
      Feedback.submitted_by_ip(@feedback.ip).recent.count >= 5
    end
end
