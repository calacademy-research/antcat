class ReferencesController < ApplicationController
  SUPPORTED_REFERENCE_TYPES = [ArticleReference, BookReference, MissingReference, NestedReference, UnknownReference]

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :ensure_user_is_editor, only: [:destroy]
  before_action :set_reference, only: [:show, :edit, :update, :destroy]

  def index
    @references = Reference.no_missing.order_by_author_names_and_year.includes(:document).paginate(page: params[:page])
  end

  def show
    @editors_reference_view_object = Editors::ReferenceViewObject.new(@reference, session)
  end

  def new
    @reference = if params[:nesting_reference_id]
                   NestedReference.new(
                     citation_year: params[:citation_year],
                     pagination: "Pp. XX-XX in:",
                     nesting_reference_id: params[:nesting_reference_id]
                   )
                 elsif params[:reference_to_copy]
                   reference_to_copy = Reference.find(params[:reference_to_copy])
                   References::NewFromCopy[reference_to_copy]
                 else
                   ArticleReference.new
                 end
  end

  def create
    @reference = reference_type_from_params.new

    if reference_form.save
      @reference.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: "Reference was successfully added."
    else
      render :new
    end
  end

  def edit
  end

  def update
    @reference = set_reference_type

    if reference_form.save
      @reference.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: "Reference was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    # Grab key before reference author names are deleted.
    activity_parameters = { name: @reference.keey }

    if @reference.destroy
      @reference.create_activity :destroy, current_user, parameters: activity_parameters
      redirect_to references_path, notice: 'Reference was successfully deleted.'
    else
      redirect_to reference_path(@reference), alert: @reference.errors.full_messages.to_sentence
    end
  end

  private

    def set_reference
      @reference = Reference.find(params[:id])
    end

    def reference_params
      params.require(:reference).permit(
        :author_names_string,
        :author_names_suffix,
        :bolton_key,
        :citation,
        :citation_year,
        :date,
        :doi,
        :editor_notes,
        :journal_name,
        :nesting_reference_id,
        :online_early,
        :pagination,
        :public_notes,
        :publisher_string,
        :series_volume_issue,
        :taxonomic_notes,
        :title,
        document_attributes: [:id, :file, :url, :public]
      )
    end

    def reference_form
      ReferenceForm.new(@reference, reference_params, request.host, ignore_duplicates: params[:ignore_duplicates].present?)
    end

    def set_reference_type
      reference = @reference.becomes reference_type_from_params
      reference.type = reference_type_from_params
      reference
    end

    def reference_type_from_params
      reference_class = SUPPORTED_REFERENCE_TYPES.find { |klass| klass.name == params[:reference_type].classify }
      reference_class || raise("reference type is not supported")
    end
end
