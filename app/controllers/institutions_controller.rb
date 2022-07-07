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

    @institution.grscicoll_identifier = trim_grscicoll_identifier(@institution.grscicoll_identifier)

    if @institution.save
      @institution.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: 'Successfully created institution.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @institution = find_institution
  end

  def update
    @institution = find_institution

    @institution.attributes = institution_params
    @institution.grscicoll_identifier = trim_grscicoll_identifier(@institution.grscicoll_identifier)

    if @institution.save
      @institution.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: "Successfully updated institution."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    institution = find_institution

    institution.destroy!
    institution.create_activity Activity::DESTROY, current_user

    redirect_to institutions_path, notice: 'Institution was successfully deleted.'
  end

  private

    def find_institution
      Institution.find(params[:id])
    end

    def institution_params
      params.require(:institution).permit(:abbreviation, :name, :grscicoll_identifier)
    end

    def trim_grscicoll_identifier grscicoll_identifier
      return unless grscicoll_identifier
      grscicoll_identifier.delete_prefix(Institution::GRSCICOLL_BASE_URL)
    end
end
