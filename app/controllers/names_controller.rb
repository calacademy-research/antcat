class NamesController < ApplicationController
  before_action :ensure_user_is_editor, except: [:show]
  before_action :set_name, only: [:show, :edit, :update, :destroy]

  def show
    @table_refs = @name.what_links_here
  end

  def edit
  end

  def update
    if @name.update(name_params)
      @name.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to name_path(@name), notice: "Successfully updated name."
    else
      render :edit
    end
  end

  def destroy
    if @name.destroy
      @name.create_activity :destroy, current_user
      redirect_to root_path, notice: "Successfully deleted name."
    else
      redirect_to name_path(@name), alert: @name.errors.full_messages.to_sentence
    end
  end

  private

    def set_name
      @name = Name.find(params[:id])
    end

    def name_params
      params.require(:name).permit(:name)
    end
end
