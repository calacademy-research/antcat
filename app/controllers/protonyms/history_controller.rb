module Protonyms
  class HistoryController < ApplicationController
    def index
      @comparer = Protonym.revision_comparer_for params[:protonym_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
