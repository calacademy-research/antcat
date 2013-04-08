# coding: UTF-8
class SynonymsController < ApplicationController

  def create
    @taxon = Taxon.find params[:taxa_id]
    synonym = Taxon.find_by_name params[:name]
    error_message = ''
    unless synonym
      error_message = 'Taxon not found'
    else
      Synonym.create! senior_synonym_id: params[:taxa_id], junior_synonym_id: synonym.id

    end
    json = {success: !!synonym, error_message: error_message}.to_json
    render json: json, content_type: 'text/html'
  end

  def destroy
    Synonym.find(params[:id]).destroy
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

end
