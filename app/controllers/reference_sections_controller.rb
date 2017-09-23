class ReferenceSectionsController < ApplicationController
  before_action :authenticate_editor, except: :show
  before_action :set_reference_section, only: [:update, :destroy]

  def index
    @reference_sections = ReferenceSection.all
    @reference_sections = @reference_sections.search_objects(search_params) if params[:q].present?
    @reference_sections = @reference_sections.paginate(page: params[:page], per_page: 100)
  end

  def show
    @comparer = ReferenceSection.revision_comparer_for params[:id],
      params[:selected_id], params[:diff_with_id]
  end

  def update
    title_taxt, subtitle_taxt, references_taxt = taxts_from_params
    @item.update title_taxt: title_taxt,
                 subtitle_taxt: subtitle_taxt,
                 references_taxt: references_taxt
    render_json @item
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    title_taxt, subtitle_taxt, references_taxt = taxts_from_params

    item = ReferenceSection.create taxon: taxon,
                                   title_taxt: title_taxt,
                                   subtitle_taxt: subtitle_taxt,
                                   references_taxt: references_taxt
    render_json item
  end

  def destroy
    @item.destroy
    render json: { success: true }
  end

  private
    def set_reference_section
      @item = ReferenceSection.find params[:id]
    end

    def search_params
      params.slice :search_type, :q
    end

    def taxts_from_params
      title_taxt = TaxtConverter[params[:title_taxt]].from_editor_format
      subtitle_taxt = TaxtConverter[params[:subtitle_taxt]].from_editor_format
      references_taxt = TaxtConverter[params[:references_taxt]].from_editor_format

      [title_taxt, subtitle_taxt, references_taxt]
    end

    def render_json item
      json = {
        content: render_to_string(partial: 'reference_sections/panel', locals: { item: item }),
        id: item.id,
        success: item.errors.empty?
      }
      render json: json
    end
end
