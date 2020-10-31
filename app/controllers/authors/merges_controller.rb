# frozen_string_literal: true

module Authors
  class MergesController < ApplicationController
    before_action :ensure_user_is_editor

    def new
      @author = find_author
    end

    def show
      @author = find_author
      @author_to_merge = find_author_to_merge

      unless @author_to_merge
        redirect_to({ action: :new }, alert: "Author to merge must be specified.")
      end
    end

    def create
      author = find_author
      author_to_merge = find_author_to_merge

      names_for_activity = author_to_merge.names.map(&:name).join(", ")
      author.merge author_to_merge
      author.create_activity Activity::MERGE_AUTHORS, current_user, parameters: { names: names_for_activity }

      redirect_to author, notice: 'Probably merged authors.'
    end

    private

      def find_author
        Author.find(params[:author_id])
      end

      def find_author_to_merge
        Author.find_by(id: params[:author_to_merge_id])
      end
  end
end
