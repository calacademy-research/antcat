class ReferenceSectionsController < ApplicationController
  before_action :authenticate_editor
  before_action :set_reference_section, only: [:show, :update, :destroy]

  def show
  end

  def update
    title_taxt, subtitle_taxt, references_taxt = taxts_from_params
    @item.update_attributes title_taxt: title_taxt,
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

    def taxts_from_params
      title_taxt = Taxt.from_editable params[:title_taxt]
      subtitle_taxt = Taxt.from_editable params[:subtitle_taxt]
      references_taxt = Taxt.from_editable params[:references_taxt]

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
