# coding: UTF-8
class SynonymsController < ApplicationController

  def create
    @taxon = Taxon.find params[:taxa_id]
    synonym = Taxon.find_by_name params[:name]
    unless synonym
      error_message = 'Taxon not found'
    else
      error_message = ''
      if Synonym.find_by_senior_synonym_id_and_junior_synonym_id params[:taxa_id], synonym.id
        error_message = 'This taxon is already a junior synonym'
      else
        Synonym.create! senior_synonym_id: params[:taxa_id], junior_synonym_id: synonym.id
      end
    end

    json = {
      content: render_to_string(partial: 'taxa/synonyms_section', locals: {
        taxon: @taxon, title: 'Junior synonyms', association_selector: :synonyms_as_senior,
        synonym_field_selector: :junior_synonym}),
      success: error_message.blank?,
      error_message: error_message
    }.to_json

    render json: json, content_type: 'text/html'
  end

  def destroy
    Synonym.find(params[:id]).destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

end
