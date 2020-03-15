class FeedbackController < ApplicationController
  BANNED_IPS = ["46.161.9.20", "46.161.9.51", "46.161.9.22"]

  before_action :ensure_user_is_superadmin, only: [:destroy]
  before_action :ensure_user_is_at_least_helper, except: [:create]
  before_action :set_feedback, only: [:show, :destroy, :close, :reopen]

  invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

  def index
    @feedbacks = Feedback.by_status_and_date.includes(:user).paginate(page: params[:page], per_page: 10)
  end

  def show
    @new_comment = Comment.build_comment @feedback, current_user
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.ip = request.remote_ip

    if ip_banned? || rate_throttle?
      render json: <<~MSG, status: :unprocessable_entity
        You have already posted a couple of feedbacks in the last few minutes. Thanks for that!
        Please wait for a few minutes while we are trying to figure out if you are a bot...
      MSG
      return
    end

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    if @feedback.save
      @feedback.create_activity :create, current_user
      render json: feedback_success_callout, status: :created
    else
      render json: @feedback.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback.destroy
    @feedback.create_activity :destroy, current_user
    redirect_to feedback_index_path, notice: "Feedback item was successfully deleted."
  end

  def close
    @feedback.close!
    @feedback.create_activity :close_feedback, current_user
    redirect_to @feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    @feedback.reopen!
    @feedback.create_activity :reopen_feedback, current_user
    redirect_to @feedback, notice: "Successfully re-opened feedback item."
  end

  private

    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def feedback_params
      params[:feedback].delete(:work_email) # Honeypot.
      params.require(:feedback).permit(:comment, :name, :email, :user, :page)
    end

    def on_spam _options = {}
      render json: "You're not a bot are you? Feedback not sent. Email us?", status: :unprocessable_entity
    end

    def ip_banned?
      request.remote_ip.in? BANNED_IPS
    end

    def rate_throttle?
      return if current_user
      Feedback.submitted_by_ip(@feedback.ip).recent.count >= 5
    end

    def feedback_success_callout
      render_to_string partial: "feedback_success_callout", locals: { feedback_id: @feedback.id }
    end
end
