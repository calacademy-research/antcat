module Authors
  class MergesController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_author

    def new
    end

    def show
      @author_to_merge = Author.find_by_names(params[:author_to_merge_name]).first # TODO: Hmm.

      unless @author_to_merge
        redirect_to({ action: :new }, alert: "Author to merge must be specified.")
        return
      end
    end

    def create
      @author_to_merge = Author.find(params[:author_to_merge_id])

      names_for_activity = @author_to_merge.names.map(&:name).join(", ")
      @author.merge [@author_to_merge]
      @author.create_activity :merge_authors, parameters: { names: names_for_activity }

      redirect_to @author, notice: 'Probably merged authors.'
    end

    private

      def set_author
        @author = Author.find(params[:author_id])
      end
  end
end
