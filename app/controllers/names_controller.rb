class NamesController < ApplicationController
  before_action :ensure_user_is_editor, except: [:show]
  before_action :set_name, only: [:show, :edit, :update]

  def show
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

  private

    def set_name
      @name = Name.find(params[:id])
    end

    def name_params
      params.require(:name).permit(:name)
    end
end
