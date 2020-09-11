# frozen_string_literal: true

class NamesController < ApplicationController
  before_action :ensure_user_is_editor, except: [:show]

  def show
    @name = find_name
  end

  def edit
    @name = find_name
  end

  def update
    @name = find_name

    if @name.update(name_params)
      @name.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to name_path(@name), notice: "Successfully updated name."
    else
      render :edit
    end
  end

  private

    def find_name
      Name.find(params[:id])
    end

    def name_params
      params.require(:name).permit(:name, :non_conforming)
    end
end
