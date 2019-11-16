module Changes
  class UndosController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_change

    def show
      @undo_items = @change.undo_items
    end

    def create
      @change.undo
      @change.create_activity :undo_change, current_user, edit_summary: params[:edit_summary]
      redirect_to changes_path, notice: "Undid the change ##{@change.id}."
    rescue Change::UndoNameIdConflict => e
      redirect_to change_path(@change), notice: "Cannot undo as it would create a name_id conflict with name ##{e.message}."
    end

    private

      def set_change
        @change = Change.find params[:change_id]
      end
  end
end
