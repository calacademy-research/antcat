# coding: UTF-8
class ReferenceSectionsController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def update
    @item = ReferenceSection.find params[:id]
    title_taxt = Taxt.from_editable params[:title_taxt]
    subtitle_taxt = Taxt.from_editable params[:subtitle_taxt]
    references_taxt = Taxt.from_editable params[:references_taxt]
    @item.update_attributes! title_taxt: title_taxt, subtitle_taxt: subtitle_taxt, references_taxt: references_taxt
    render_json false
  end

  def create
    taxon = Taxon.find params[:taxa_id]
    title_taxt = Taxt.from_editable params[:title_taxt]
    subtitle_taxt = Taxt.from_editable params[:subtitle_taxt]
    references_taxt = Taxt.from_editable params[:references_taxt]
    @item = ReferenceSection.create! taxon: taxon, title_taxt: title_taxt, subtitle_taxt: subtitle_taxt, references_taxt: references_taxt
    render_json true
  end

  def destroy
    @item = ReferenceSection.find params[:id]
    @item.destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  ###

  def render_json is_new
    json = {
      isNew: is_new,
      content: render_to_string(partial: 'reference_sections/panel', locals: {item: @item}),
      id: @item.id,
      success: @item.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
