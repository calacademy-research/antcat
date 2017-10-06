class ReferencePickersController < ApplicationController
  before_action :authenticate_editor

  def show
    reference = Reference.find params[:id] if params[:id].present?

    # TODO there's no happy path for `references` here?
    if params[:q].present?
      params[:q].strip!
      references = References::Search::FulltextWithExtractedKeywords[params]
    end

    render partial: "reference_#{picker_type}s/show",
      locals: { references: references, reference: reference }
  end
end
