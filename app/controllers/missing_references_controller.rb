# coding: UTF-8
class MissingReferencesController < ApplicationController
  before_filter :authenticate_editor, except: [:index]
  skip_before_filter :authenticate_editor, if: :preview?

  def index
    @missing_references = Protonym.select(:citation)
      .joins(authorship: :reference)
      .where("references.type = 'MissingReference'")
      .group(:citation)
      .order(:citation)
  end

  def edit
    @missing_reference_citation = MissingReference.find params[:id]
    @replacement = nil
  end

  def update
    @missing_reference_citation = MissingReference.find params[:id] rescue nil
    @replacement = Reference.find params[:replacement_id] rescue nil


    MissingReference.find(@missing_reference_citation).replace_with @replacement

    redirect_to missing_references_path
  end

end
