class InstitutionsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: [:new, :create]
  before_action :ensure_can_edit_catalog, only: [:edit, :update]
  before_action :authenticate_superadmin, only: [:destroy]
  before_action :set_institution, only: [:edit, :update, :destroy]

  def index
    @institutions = Institution.order(:abbreviation)
  end

  def show
    @comparer = Institution.revision_comparer_for params[:id],
      params[:selected_id], params[:diff_with_id]
  end

  def new
    @institution = Institution.new
  end

  def edit
  end

  def create
    @institution = Institution.new institution_params

    if @institution.save
      @institution.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: 'Successfully created institution.'
    else
      render :new
    end
  end

  def update
    if @institution.update institution_params
      @institution.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to @institution, notice: "Successfully updated institution."
    else
      render :edit
    end
  end

  def destroy
    @institution.destroy
    @institution.create_activity :destroy
    redirect_to institutions_path, notice: 'Institution was successfully deleted.'
  end

  private

    def institution_params
      params.require(:institution).permit(:name, :abbreviation)
    end

    def set_institution
      @institution = Institution.find params[:id]
    end
end
