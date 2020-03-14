class InstitutionsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: [:new, :create]
  before_action :ensure_user_is_editor, only: [:edit, :update]
  before_action :ensure_user_is_superadmin, only: [:destroy]
  before_action :set_institution, only: [:show, :edit, :update, :destroy]

  def index
    @institutions = Institution.order(:abbreviation)
  end

  def show
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
  end

  def update
    if @institution.update(institution_params)
      @institution.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: "Successfully updated institution."
    else
      render :edit
    end
  end

  def destroy
    @institution.destroy
    @institution.create_activity :destroy, current_user
    redirect_to institutions_path, notice: 'Institution was successfully deleted.'
  end

  private

    def set_institution
      @institution = Institution.find(params[:id])
    end

    def institution_params
      params.require(:institution).permit(:abbreviation, :name)
    end
end
