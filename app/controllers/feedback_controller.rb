class FeedbackController < ApplicationController
  include ActionView::Helpers::DateHelper
  include HasWhereFilters

  BANNED_IPS = ["46.161.9.20", "46.161.9.51", "46.161.9.22"]

  before_action :authenticate_superadmin, only: [:destroy]
  before_action :ensure_user_is_at_least_helper, except: [:create]
  before_action :set_feedback, only: [:show, :destroy, :close, :reopen]

  invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

  has_filters(
    open: {
      tag: :select_tag,
      options: -> { [["Open", 1], ["Closed", 0]] },
      prompt: "Status"
    }
  )

  # TODO probably remove `by_status_and_date` now that we have filters.
  def index
    @feedbacks = Feedback.by_status_and_date.filter(filter_params)
    @feedbacks = @feedbacks.includes(:user).paginate(page: params[:page], per_page: 10)
  end

  def show
    @new_comment = Comment.build_comment @feedback, current_user
  end

  def create
    @feedback = Feedback.new feedback_params
    @feedback.ip = request.remote_ip
    render_unprocessable and return if ip_banned?
    render_unprocessable and return if maybe_rate_throttle

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    respond_to do |format|
      if @feedback.save
        @feedback.create_activity :create
        format.json do
          render status: :created, json: { feedback_success_callout: feedback_success_callout }
        end
      else
        format.json { render_unprocessable }
      end
    end
  end

  def destroy
    @feedback.destroy
    @feedback.create_activity :destroy
    redirect_to feedback_index_path, notice: "Feedback item was successfully deleted."
  end

  def close
    @feedback.close
    redirect_to @feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    @feedback.reopen
    redirect_to @feedback, notice: "Successfully re-opened feedback item."
  end

  private

    def set_feedback
      @feedback = Feedback.find params[:id]
    end

    def on_spam _options = {}
      @feedback = Feedback.new feedback_params
      @feedback.errors.add :hmm, "you're not a bot are you? Feedback not sent. Email us?"
      render_unprocessable
    end

    def ip_banned?
      request.remote_ip.in? BANNED_IPS
    end

    def maybe_rate_throttle
      return if current_user # Logged-in users are never throttled.

      timespan = 5.minutes.ago
      max_feedbacks_in_timespan = 5

      if @feedback.from_the_same_ip.recently_created(timespan).
          count >= max_feedbacks_in_timespan

        @feedback.errors.add :rate_limited, <<-ERROR_MSG
          you have already posted #{max_feedbacks_in_timespan} feedbacks in the last
          #{time_ago_in_words Time.zone.at(timespan)}. Thanks for that! Please wait for
          a few minutes while we are trying to figure out if you are a bot...
        ERROR_MSG
      end
    end

    def render_unprocessable
      render json: @feedback.errors, status: :unprocessable_entity
    end

    def feedback_success_callout
      render_to_string partial: "feedback_success_callout",
        locals: { feedback_id: @feedback.id }
    end

    def feedback_params
      params[:feedback].delete :work_email
      params.require(:feedback).permit :comment, :name, :email, :user, :page
    end
end
