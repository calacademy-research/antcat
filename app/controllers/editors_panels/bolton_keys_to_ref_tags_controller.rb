module EditorsPanels
  class BoltonKeysToRefTagsController < ApplicationController
    def show
    end

    def create
      @with_ref_tags = Markdowns::BoltonKeysToRefTags[params[:bolton_content]]
      respond_to do |format|
        format.html do
          render :show
        end
        format.json do
          render json: @with_ref_tags
        end
      end
    end
  end
end
