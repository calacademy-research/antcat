module EditorsPanels
  class BoltonKeysToRefTagsController < ApplicationController
    def show
    end

    def create
      @with_ref_tags = Markdowns::BoltonKeysToRefTags[params[:bolton_content]]
      render :show
    end
  end
end
