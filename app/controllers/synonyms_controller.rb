class SynonymsController < ApplicationController
  before_action :authenticate_editor, except: :show
  before_action :set_synonym, only: [:show, :destroy, :reverse_synonymy]
  before_action :set_taxon, only: [:create, :reverse_synonymy]

  def show
  end

  def create
    synonym_taxon = Taxon.find(params[:synonym_taxon_id])
    is_junior = params[:junior]

    error_message = ''

    if synonym_taxon
      if is_junior
        junior = synonym_taxon
        senior = @taxon
      else
        junior = @taxon
        senior = synonym_taxon
      end

      if Synonym.find_by(senior_synonym: senior, junior_synonym: junior) ||
          Synonym.find_by(senior_synonym: junior, junior_synonym: senior)
        error_message = 'This taxon is already a synonym'
      else
        synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
        synonym.paper_trail.touch_with_version
      end
    else
      error_message = 'Taxon not found'
    end

    render json: { content: content(@taxon), success: error_message.blank?, error_message: error_message }
  end

  def destroy
    @synonym.destroy
    render json: { success: true }
  end

  def reverse_synonymy
    new_junior = @synonym.senior_synonym
    new_senior = @synonym.junior_synonym

    Synonym.where(junior_synonym_id: new_junior, senior_synonym_id: new_senior).destroy_all
    Synonym.where(senior_synonym_id: new_junior, junior_synonym_id: new_senior).destroy_all
    @synonym = Synonym.create! junior_synonym: new_junior, senior_synonym: new_senior
    @synonym.paper_trail.touch_with_version

    render json: { content: content(@taxon), success: true, error_message: '' }
  end

  private

    def content taxon
      render_to_string partial: 'taxa/not_really_form/junior_and_senior_synonyms_section', locals: { taxon: taxon }
    end

    def set_synonym
      @synonym = Synonym.find params[:id]
    end

    def set_taxon
      @taxon = Taxon.find params[:taxa_id]
    end
end
