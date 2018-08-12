module Changes
  class UndosController < ApplicationController
    before_action :ensure_can_edit_catalog
    before_action :set_change

    def show
      @undo_items = @change.undo_items
    end

    # TODO handle error, if any.
    def create
      @change.undo
      @change.create_activity :undo_change, edit_summary: params[:edit_summary]
      redirect_to changes_path, notice: "Undid the change ##{@change.id}."
    end

    private

      def set_change
        @change = Change.find params[:change_id]
      end
  end
end
