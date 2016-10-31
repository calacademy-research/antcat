class MissingReferencesController < ApplicationController
  before_action :authenticate_editor, except: [:index]
  before_action :set_reference, only: [:edit, :update]
  layout "references"

  def index
    ids = Protonym.joins(authorship: :reference)
      .where("references.type = 'MissingReference'")
      .uniq.pluck('references.id')

    @missing_references = MissingReference.where(id: ids).order(:citation)
  end

  def edit
  end

  def update
    @replacement = Reference.find params[:replacement_id] rescue nil

    unless @replacement
      flash[:warning] = "A replacement ID is required."
      render :edit
      return
    end

    @reference.replace_citation_with @replacement

    redirect_to missing_references_path,
      notice: "Probably replaced missing reference."
  end

  private
    def set_reference
      @reference = MissingReference.find params[:id]
    end
end
