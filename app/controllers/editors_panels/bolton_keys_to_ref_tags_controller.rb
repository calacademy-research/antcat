# frozen_string_literal: true

module EditorsPanels
  # Editing tool (also used by the "Convert Bolton keys" button in taxt editors), for helpers and editors.
  class BoltonKeysToRefTagsController < ApplicationController
    TOO_LARGE_MESSAGE = "Too much content to convert at once " \
                        "(at most #{Markdowns::BoltonKeysToRefTags::MAX_CONTENT_LENGTH} characters " \
                        "and #{Markdowns::BoltonKeysToRefTags::MAX_BOLTON_KEYS} references). Please convert it in parts."

    before_action :ensure_user_is_at_least_helper

    def show
    end

    def create
      @with_ref_tags = Markdowns::BoltonKeysToRefTags[params[:bolton_content].to_s]

      respond_to do |format|
        format.html do
          render :show
        end
        format.json do
          render json: @with_ref_tags
        end
      end
    rescue Markdowns::BoltonKeysToRefTags::TooLarge
      respond_to do |format|
        format.html do
          flash.now[:alert] = TOO_LARGE_MESSAGE
          render :show, status: :content_too_large
        end
        format.json do
          render json: { error: TOO_LARGE_MESSAGE }, status: :content_too_large
        end
      end
    end
  end
end
