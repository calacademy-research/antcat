class FeedbackController < ApplicationController
  def create
    @feedback = Feedback.new feedback_params
    @feedback.ip = request.remote_ip

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    respond_to do |format|
      if @feedback.save
        format.json do
          json = { feedback_success_callout: feedback_success_callout }
          render json: json, status: :created
        end
      else
        format.json do
          render json: @feedback.errors, status: :unprocessable_entity
        end
      end
    end
  end

  private
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def feedback_success_callout
      render_to_string partial: "feedback_success_callout",
        locals: { feedback_id: @feedback.id }
    end

    def feedback_params
      params.require(:feedback)
        .permit :comment, :name, :email, :user, :page
    end
end
