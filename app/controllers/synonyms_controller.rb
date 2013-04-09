# coding: UTF-8
class SynonymsController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def create
    taxon = Taxon.find params[:taxa_id]
    synonym_taxon = Taxon.find_by_name params[:name]
    is_junior = params[:junior].present?

    title = ''
    error_message = ''
    synonyms = []

    if synonym_taxon
      if is_junior
        junior = synonym_taxon
        senior = taxon
        title = 'Junior synonyms'
      else
        junior = taxon
        senior = synonym_taxon
        title = 'Senior synonyms'
      end
      if Synonym.find_by_senior_synonym_id_and_junior_synonym_id senior.id, junior.id
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
      content: render_to_string(partial: 'taxa/synonyms_section', locals: {taxon: taxon, title: title, synonyms: synonyms}),
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
    new_junior.become_junior_synonym_of new_senior
    ReverseSynonymyEdit.create! new_junior: new_junior, new_senior: new_senior, user: current_user

    content = render_to_string(partial: 'taxa/junior_and_senior_synonyms_section', locals: {taxon: taxon})
    json = {content: content, success: true, error_message: ''}.to_json
    render json: json, content_type: 'text/html'
  end

end
