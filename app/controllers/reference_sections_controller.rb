class ReferenceSectionsController < ApplicationController
  before_filter :authenticate_editor

  def show
    @item = ReferenceSection.find params[:id]
  end

  def update
    item = ReferenceSection.find params[:id]
    title_taxt = Taxt.from_editable params[:title_taxt]
    subtitle_taxt = Taxt.from_editable params[:subtitle_taxt]
    references_taxt = Taxt.from_editable params[:references_taxt]
    item.update_attributes title_taxt: title_taxt,
      subtitle_taxt: subtitle_taxt,
      references_taxt: references_taxt

    render_json item
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    title_taxt = Taxt.from_editable params[:title_taxt]
    subtitle_taxt = Taxt.from_editable params[:subtitle_taxt]
    references_taxt = Taxt.from_editable params[:references_taxt]
    item = ReferenceSection.create taxon: taxon,
      title_taxt: title_taxt,
      subtitle_taxt: subtitle_taxt,
      references_taxt: references_taxt

    render_json item
  end

  def destroy
    item = ReferenceSection.find params[:id]
    item.destroy
    render json: { success: true }
  end

  private
    def render_json item
      json = {
        content: render_to_string(partial: 'reference_sections/panel', locals: { item: item }),
        id: item.id,
        success: item.errors.empty?
      }
      render json: json
    end

    # TODO create `def set_reference_section`
end
