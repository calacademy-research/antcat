# frozen_string_literal: true

class FeedbacksController < ApplicationController
  RECAPTCHA_V3_ACTION = 'feedback'

  before_action :ensure_user_is_at_least_helper, except: [:new, :create]
  before_action :ensure_user_is_superadmin, only: [:destroy]

  def index
    @feedbacks = Feedback.by_status_and_date.includes(:user).paginate(page: params[:page], per_page: 10)
  end

  def show
    @feedback = find_feedback
    @new_comment = Comment.build_comment(@feedback, current_user)
  end

  def new
    @feedback = Feedback.new(page: params[:page])
  end

  def create
    @feedback = Feedback.new(feedback_params)

    unless recaptcha_v3_valid?(params[:recaptcha_token], RECAPTCHA_V3_ACTION)
      flash.now[:error] = "reCAPTCHA verification failed. Please try again."
      return render :new
    end

    @feedback.ip = request.remote_ip

    if rate_throttle?(@feedback.ip)
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
      @feedback.create_activity Activity::CREATE, current_user
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
      @feedback.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @feedback, notice: "Successfully updated feedback."
    else
      render :edit
    end
  end

  def destroy
    feedback = find_feedback

    feedback.destroy!
    feedback.create_activity Activity::DESTROY, current_user

    redirect_to feedbacks_path, notice: "Feedback item was successfully deleted."
  end

  def close
    feedback = find_feedback

    feedback.close!
    feedback.create_activity Activity::CLOSE_FEEDBACK, current_user

    redirect_to feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    feedback = find_feedback

    feedback.reopen!
    feedback.create_activity Activity::REOPEN_FEEDBACK, current_user

    redirect_to feedback, notice: "Successfully re-opened feedback item."
  end

  private

    def find_feedback
      Feedback.find(params[:id])
    end

    def feedback_params
      params.require(:feedback).permit(:comment, :name, :email, :user, :page)
    end

    def rate_throttle? remote_ip
      return if current_user
      Feedback.submitted_by_ip(remote_ip).recent.count >= 5
    end
end
