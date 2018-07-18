class ReferencesController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show, :autocomplete]
  before_action :set_reference, only: [:show, :edit, :update, :destroy]

  def index
    @references = Reference.no_missing.order_by_author_names_and_year.
      includes_document.paginate(page: params[:page])
  end

  def show
  end

  def new
    @reference = ArticleReference.new

    if params[:nesting_reference_id]
      build_nested_reference params[:nesting_reference_id], params[:citation_year]
    elsif params[:reference_to_copy]
      reference_to_copy = Reference.find params[:reference_to_copy]
      @reference = References::NewFromCopy[reference_to_copy]
    end
  end

  def edit
  end

  def create
    @reference = new_reference

    if save
      @reference.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: <<-MSG
        Reference was successfully created.
        <strong>#{view_context.link_to 'Back to the index', references_path}</strong>
        or
        <strong>#{view_context.link_to 'add another?', new_reference_path}</strong>
      MSG
    else
      render :new
    end
  end

  def update
    @reference = set_reference_type

    if save
      @reference.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: <<-MSG
        Reference was successfully updated.
        <strong>#{view_context.link_to 'Back to the index', references_path}</strong>.
      MSG
    else
      render :edit
    end
  end

  def destroy
    if @reference.destroy
      @reference.create_activity :destroy, edit_summary: params[:edit_summary]
      redirect_to references_path, notice: 'Reference was successfully deleted.'
    else
      redirect_to reference_path(@reference),
        alert: @reference.errors.full_messages.to_sentence
    end
  end

  # For at.js. Not as advanced as `#autocomplete`.
  def linkable_autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteLinkableReferences[search_query]
      end
    end
  end

  def autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteReferences[search_query]
      end
    end
  end

  private

    def build_nested_reference reference_id, citation_year
      @reference = @reference.becomes NestedReference
      @reference.citation_year = citation_year
      @reference.pages_in = "Pp. XX-XX in:"
      @reference.nesting_reference_id = reference_id
    end

    def save
      References::SaveFromForm[@reference, reference_params, params, request.host]
    end

    def new_reference
      reference_type_from_params.new
    end

    def set_reference_type
      reference = @reference.becomes reference_type_from_params
      reference.type = reference_type_from_params
      reference
    end

    def reference_type_from_params
      reference_type = params[:reference_type]
      raise "#{reference_type} is not supported" unless reference_type.in?(
        ['ArticleReference', 'BookReference', 'MissingReference', 'NestedReference', 'UnknownReference']
      )
      reference_type.constantize
    end

    def reference_params
      params.require(:reference).permit(
        :citation_year,
        :doi,
        :date,
        :title,
        :series_volume_issue,
        :journal_name,
        :publisher_string,
        :public_notes,
        :editor_notes,
        :taxonomic_notes,
        :pages_in,
        :nesting_reference_id,
        :citation,
        :author_names_string,
        { document_attributes: [:id, :file, :url, :public] }
      )
    end

    def set_reference
      @reference = Reference.find params[:id]
    end
end
