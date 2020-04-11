# frozen_string_literal: true

class ReferencesController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :ensure_user_is_editor, only: [:destroy]

  def index
    @references = Reference.order_by_author_names_and_year.includes(:document).paginate(page: params[:page])
  end

  def show
    # TODO: `journal` and `publisher` are not eager loaded (STI `belongs_to`s).
    @reference = Reference.eager_load(:document, author_names: :author).find(params[:id])
    @editors_reference_presenter = Editors::ReferencePresenter.new(@reference, session: session)
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
    @reference_form = ReferenceForm.new(@reference, {})
  end

  def create
    @reference = reference_type_from_params.new
    @reference_form = ReferenceForm.new(@reference, reference_params, ignore_duplicates: params[:ignore_duplicates].present?)

    if @reference_form.save
      @reference.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: "Reference was successfully added."
    else
      @reference_form.collect_errors!
      render :new
    end
  end

  def edit
    @reference = find_reference
    @reference_form = ReferenceForm.new(@reference, {})
  end

  def update
    @reference = becomes_reference_type_from_params(find_reference)
    @reference_form = ReferenceForm.new(@reference, reference_params, ignore_duplicates: params[:ignore_duplicates].present?)

    if @reference_form.save
      @reference.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to reference_path(@reference), notice: "Reference was successfully updated."
    else
      @reference_form.collect_errors!
      render :edit
    end
  end

  def destroy
    reference = find_reference

    # Grab key before reference author names are deleted.
    activity_parameters = { name: reference.keey }

    if reference.destroy
      reference.create_activity :destroy, current_user, parameters: activity_parameters
      redirect_to references_path, notice: 'Reference was successfully deleted.'
    else
      redirect_to reference_path(reference), alert: reference.errors.full_messages.to_sentence
    end
  end

  private

    def find_reference
      Reference.find(params[:id])
    end

    def reference_params
      params.require(:reference).permit(
        :author_names_string,
        :author_names_suffix,
        :bolton_key,
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
        document_attributes: [:id, :file, :url]
      )
    end

    # NOTE: This is so references can be converted between types.
    def becomes_reference_type_from_params reference
      type_casted = reference.becomes(reference_type_from_params)
      type_casted.type = reference_type_from_params
      type_casted
    end

    def reference_type_from_params
      reference_class = Reference::CONCRETE_SUBCLASS_NAMES.find { |class_name| class_name == params[:reference_type] }
      reference_class.constantize || raise("reference type is not supported")
    end
end
