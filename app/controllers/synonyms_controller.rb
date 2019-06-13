class SynonymsController < ApplicationController
  before_action :ensure_user_is_editor
  before_action :set_synonym, only: [:destroy]
  before_action :set_taxon, only: [:create]

  def create
    junior, senior = junior_and_senior

    if already_a_synonym? junior, senior
      render json: { error_message: 'This taxon is already a synonym' }, status: :conflict
    else
      synonym = Synonym.create!(senior_synonym: senior, junior_synonym: junior)
      synonym.create_activity :create

      render json: { content: content(@taxon) }
    end
  end

  def destroy
    @synonym.destroy
    @synonym.create_activity :destroy
    head :ok
  end

  private

    def junior_and_senior
      synonym_taxon = Taxon.find(params[:synonym_taxon_id])

      if params[:junior]
        [synonym_taxon, @taxon]
      else
        [@taxon, synonym_taxon]
      end
    end

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
