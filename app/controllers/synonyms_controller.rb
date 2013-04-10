# coding: UTF-8
class SynonymsController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def create
    taxon = Taxon.find params[:taxa_id]
    synonym_taxon = Taxon.find_by_name params[:name]
    is_junior = params[:junior]

    title = ''
    error_message = ''
    junior_or_senior = ''
    synonyms = []

    if synonym_taxon
      if is_junior
        junior = synonym_taxon
        senior = taxon
        title = 'Junior synonyms'
        junior_or_senior = 'junior'
      else
        junior = taxon
        senior = synonym_taxon
        title = 'Senior synonyms'
        junior_or_senior = 'senior'
      end
      if Synonym.find_by_senior_synonym_id_and_junior_synonym_id(senior.id, junior.id) or
         Synonym.find_by_senior_synonym_id_and_junior_synonym_id(junior.id, senior.id)
        error_message = 'This taxon is already a synonym'
      else
        Synonym.create! senior_synonym_id: senior.id, junior_synonym_id: junior.id
        if is_junior
          synonyms = taxon.junior_synonyms_with_names
        else
          synonyms = taxon.senior_synonyms_with_names
        end
      end
    else
      error_message = 'Taxon not found'
    end

    json = {
      content: render_to_string(partial: 'taxa/synonyms_section', locals: {
        taxon: taxon, title: title, synonyms: synonyms, junior_or_senior: junior_or_senior
      }),
      success: error_message.blank?,
      error_message: error_message,
    }.to_json

    render json: json, content_type: 'text/html'
  end

  def destroy
    Synonym.find(params[:id]).destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  def reverse_synonymy
    synonym = Synonym.find params[:id]
    taxon = Taxon.find params[:taxa_id]

    new_junior = synonym.senior_synonym
    new_senior = synonym.junior_synonym

    Synonym.where(junior_synonym_id: new_junior, senior_synonym_id: new_senior).destroy_all
    Synonym.where(senior_synonym_id: new_junior, junior_synonym_id: new_senior).destroy_all
    Synonym.create! junior_synonym: new_junior, senior_synonym: new_senior

    content = render_to_string(partial: 'taxa/junior_and_senior_synonyms_section', locals: {taxon: taxon})
    json = {content: content, success: true, error_message: ''}.to_json
    render json: json, content_type: 'text/html'
  end

end
