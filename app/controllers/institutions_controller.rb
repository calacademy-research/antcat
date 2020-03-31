# frozen_string_literal: true

class InstitutionsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: [:new, :create]
  before_action :ensure_user_is_editor, only: [:edit, :update]
  before_action :ensure_user_is_superadmin, only: [:destroy]

  def index
    @institutions = Institution.order(:abbreviation)
  end

  def show
    @institution = find_institution
  end

  def new
    @institution = Institution.new
  end

  def create
    @institution = Institution.new(institution_params)

    if @institution.save
      @institution.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: 'Successfully created institution.'
    else
      render :new
    end
  end

  def edit
    @institution = find_institution
  end

  def update
    @institution = find_institution

    if @institution.update(institution_params)
      @institution.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: "Successfully updated institution."
    else
      render :edit
    end
  end

  def destroy
    institution = find_institution

    institution.destroy!
    institution.create_activity :destroy, current_user

    redirect_to institutions_path, notice: 'Institution was successfully deleted.'
  end

  private

    def find_institution
      Institution.find(params[:id])
    end

    def institution_params
      params.require(:institution).permit(:abbreviation, :name)
    end
end
