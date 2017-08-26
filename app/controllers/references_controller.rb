class ReferencesController < ApplicationController
  before_action :authenticate_editor, except: [:index, :download, :autocomplete,
    :search_help, :show, :search, :endnote_export, :wikipedia_export, :latest_additions,
    :latest_changes]
  before_action :authenticate_superadmin, only: [:approve_all]
  before_action :set_reference, only: [:show, :edit, :update, :destroy,
    :start_reviewing, :finish_reviewing, :restart_reviewing, :wikipedia_export]
  before_action :redirect_if_search_matches_id, only: [:search]

  def index
    @references = Reference.list_references params
  end

  def show
  end

  def new
    @reference = Reference.new

    if params[:nesting_reference_id]
      build_nested_reference params[:nesting_reference_id], params[:citation_year]
    elsif params[:reference_to_copy]
      reference_to_copy = Reference.find params[:reference_to_copy]
      @reference = References::NewFromCopy.new(reference_to_copy).call
    end
  end

  def edit
  end

  # We manually create activities for the feed in `#create, #update and #destroy`,
  # or we may end up with tons of activities instead of one.
  def create
    @reference = new_reference

    if save
      @reference.create_activity :create
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
      @reference.create_activity :update
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
      @reference.create_activity :destroy
      redirect_to references_path, notice: 'Reference was successfully destroyed.'
    else
      if @reference.errors.present?
        flash[:warning] = @reference.errors.full_messages.to_sentence
      end
      redirect_to reference_path(@reference)
    end
  end

  def download
    document = ReferenceDocument.find params[:id]
    if document.downloadable?
      redirect_to document.actual_url
    else
      head :unauthorized
    end
  end

  # TODO handle error, if any. Also in `#finish_reviewing` and `#restart_reviewing`.
  # TODO allow JSON requests.
  def start_reviewing
    @reference.start_reviewing!
    make_default_reference @reference
    redirect_to latest_additions_references_path
  end

  def finish_reviewing
    @reference.finish_reviewing!
    redirect_to latest_additions_references_path
  end

  def restart_reviewing
    @reference.restart_reviewing!
    make_default_reference @reference
    redirect_to latest_additions_references_path
  end

  # TODO handle error, if any.
  def approve_all
    Reference.approve_all
    redirect_to latest_changes_references_path, notice: "Approved all references."
  end

  def search
    user_is_searching = params[:q].present? || params[:author_q].present?
    return redirect_to action: :index unless user_is_searching

    unparsable_author_names_error_message = <<-MSG
      Could not parse author names. Start by typing a name, wait for a while
      and then click on one of the suggestions. It is possible to manually
      type the query (for example "Wilson, E. O.; Billen, J.;"),
      but the names must exactly match the names in the database
      ("Wilson" or "Wilson, E." will not work), and the query has to be
      formatted like in the first example. Still not working? Email us!
    MSG

    @references = if params[:search_type] == "author"
                    begin
                      Reference.author_search params[:author_q], params[:page]
                    rescue Citrus::ParseError
                      flash.now.alert = unparsable_author_names_error_message
                      Reference.none.paginate page: 9999
                    end
                  else
                    Reference.do_search params
                  end
  end

  def search_help
  end

  def latest_additions
    options = { order: :created_at, page: params[:page] }
    @references = Reference.list_references options
  end

  def latest_changes
    options = { order: :updated_at, page: params[:page] }
    @references = Reference.list_references options
  end

  def endnote_export
    id = params[:id]
    searching = params[:q].present?

    references =
      if id
        # `where` and not `find` because we need to return an array.
        Reference.where(id: id)
      elsif searching
        Reference.do_search params.merge endnote_export: true
      else
        # I believe it's not possible to get here from the GUI, but the route
        # is not disabled. http://localhost:3000/references/endnote_export
        Reference.list_all_references_for_endnote
      end

    render plain: Exporters::Endnote::Formatter.format(references)

    rescue
      render plain: <<-MSG.squish
        Looks like something went wrong.
        Exporting missing references is not supported.
        If you tried to export a list of references,
        try to filter the query with "type:nomissing".
      MSG
  end

  def wikipedia_export
    render plain: Wikipedia::ReferenceExporter.export(@reference)
  end

  # For at.js. Not as advanced as `#autocomplete`.
  def linkable_autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::LinkableReferences.new(search_query).call
      end
    end
  end

  def autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::References.new(search_query).call
      end
    end
  end

  private
    def redirect_if_search_matches_id
      params[:q] ||= ''
      params[:q].strip!

      if params[:q].match(/^\d{5,}$/)
        id = params[:q]
        return redirect_to reference_path(id) if Reference.exists? id
      end
    end

    def build_nested_reference reference_id, citation_year
      @reference = @reference.becomes NestedReference
      @reference.citation_year = citation_year
      @reference.pages_in = "Pp. XX-XX in:"
      @reference.nesting_reference_id = reference_id
    end

    def make_default_reference reference
      DefaultReference.set session, reference
    end

    def save
      References::SaveFromForm.new(@reference, params, request.host).call
    end

    def new_reference
      case params[:selected_tab]
      when 'Article' then ArticleReference.new
      when 'Book'    then BookReference.new
      when 'Nested'  then NestedReference.new
      else                UnknownReference.new
      end
    end

    def set_reference_type
      selected_tab = params[:selected_tab]
      selected_tab = 'Unknown' if selected_tab == 'Other'
      type = "#{selected_tab}Reference".constantize
      reference = @reference.becomes type
      reference.type = type
      reference
    end

    def set_reference
      @reference = Reference.find params[:id]
    end
end
