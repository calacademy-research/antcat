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
      @name.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      redirect_to name_path(@name), notice: "Successfully updated name."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    def find_name
      Name.find(params.expect(:id))
    end

    def name_params
      params.expect(name: [:name, :non_conforming])
    end
end
