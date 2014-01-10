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
    @missing_reference_citation = params[:id]
  end

end
