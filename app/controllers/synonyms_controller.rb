class SynonymsController < ApplicationController
  before_action :ensure_can_edit_catalog, except: :show
  before_action :set_synonym, only: [:show, :destroy, :reverse_synonymy]
  before_action :set_taxon, only: [:create, :reverse_synonymy]

  def show
  end

  def create
    synonym_taxon = Taxon.find(params[:synonym_taxon_id])
    is_junior = params[:junior]

    error_message = ''

    if is_junior
      junior = synonym_taxon
      senior = @taxon
    else
      junior = @taxon
      senior = synonym_taxon
    end

    if already_a_synonym? junior, senior
      error_message = 'This taxon is already a synonym'
    else
      Synonym.create! senior_synonym: senior, junior_synonym: junior
    end

    if error_message.blank?
      render json: { content: content(@taxon) }
    else
      render json: { error_message: error_message }, status: :conflict
    end
  end

  def destroy
    @synonym.destroy
    head :ok
  end

  def reverse_synonymy
    new_junior = @synonym.senior_synonym
    new_senior = @synonym.junior_synonym

    Synonym.where(junior_synonym_id: new_junior, senior_synonym_id: new_senior).destroy_all
    Synonym.where(senior_synonym_id: new_junior, junior_synonym_id: new_senior).destroy_all
    Synonym.create! junior_synonym: new_junior, senior_synonym: new_senior

    render json: { content: content(@taxon) }
  end

  private

    def already_a_synonym? junior, senior
      Synonym.find_by(senior_synonym: senior, junior_synonym: junior) ||
        Synonym.find_by(senior_synonym: junior, junior_synonym: senior)
    end

    def content taxon
      render_to_string partial: 'taxa/_not_really_form/synonyms_section', locals: { taxon: taxon }
    end

    def set_synonym
      @synonym = Synonym.find params[:id]
    end

    def set_taxon
      @taxon = Taxon.find params[:taxa_id]
    end
end
