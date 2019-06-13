class ReferenceSectionsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:show, :index]
  before_action :ensure_user_is_editor, only: [:destroy]
  before_action :set_reference_section, only: [:edit, :update, :destroy]

  def index
    @reference_sections = ReferenceSection.all
    @reference_sections = @reference_sections.search_objects(search_params) if params[:q].present?
    @reference_sections = @reference_sections.includes(taxon: [:name]).paginate(page: params[:page], per_page: 30)
  end

  def show
    @comparer = ReferenceSection.revision_comparer_for params[:id],
      params[:selected_id], params[:diff_with_id]
  end

  def new
    @item = ReferenceSection.new(taxon_id: params[:taxa_id])
  end

  def edit
  end

  def update
    updated = @item.update(reference_section_params)

    if updated
      @item.create_activity :update, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @item }
      format.html do
        if updated
          redirect_to catalog_path(@item.taxon), notice: "Successfully updated reference section."
        else
          render :edit
        end
      end
    end
  end

  def create
    @item = ReferenceSection.new(reference_section_params)
    @item.taxon_id = params[:taxa_id]

    if @item.save
      @item.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to edit_taxa_path(@item.taxon), notice: "Successfully added reference section."
    else
      render :new
    end
  end

  def destroy
    @item.destroy
    @item.create_activity :destroy, edit_summary: params[:edit_summary]

    render json: { success: true }
  end

  private

    def set_reference_section
      @item = ReferenceSection.find(params[:id])
    end

    def search_params
      params.slice :search_type, :q
    end

    def reference_section_params
      params.require(:reference_section).permit(:title_taxt, :subtitle_taxt, :references_taxt)
    end

    def render_json item
      render json: {
        content: render_to_string(partial: 'reference_sections/taxt_editor_template', locals: { item: item }),
        error: item.errors.full_messages.to_sentence
      }
    end
end
