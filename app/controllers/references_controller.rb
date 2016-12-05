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
      @reference = reference_to_copy.new_from_copy
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

    # TODO create concern? There's similar logic in other controllers.
    # See if we have an exact ID match.
    search_results =  if search_query =~ /^\d{6} ?$/
                        id_matches_q = Reference.find_by id: search_query
                        [id_matches_q] if id_matches_q
                      end
    search_results ||= Reference.fulltext_search_light search_query

    respond_to do |format|
      format.json do
        results = search_results.map do |reference|
          { id: reference.id,
            author: reference.author_names_string,
            year: reference.citation_year,
            title: reference.decorate.format_title }
        end

        render json: results
      end
    end
  end

  def autocomplete
    search_query = params[:q] || ''

    search_options = {}
    keyword_params = Reference.extract_keyword_params search_query

    search_options[:reference_type] = :nomissing
    search_options[:items_per_page] = 5
    search_options.merge! keyword_params
    search_results = Reference.fulltext_search search_options

    respond_to do |format|
      format.json do
        results = search_results.map do |reference|
          search_query = if keyword_params.size == 1 # size 1 = no keyword params were matched
                           reference.title
                         else
                           format_autosuggest_keywords reference, keyword_params
                         end
          {
            search_query: search_query,
            title: reference.title,
            author: reference.author_names_string,
            year: reference.citation_year
          }
        end

        render json: results
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

    # TODO probably extract to another infamous class.
    def save
      Reference.transaction do
        clear_document_params_if_necessary
        set_pagination
        clear_nesting_reference_id unless @reference.kind_of? NestedReference
        parse_author_names_string
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference

        # Set attributes to make sure they're persisted in the form.
        @reference.attributes = params[:reference]

        # Raise if there are errors -- #save! clears the errors
        # before validating, so we need to manually raise here.
        raise ActiveRecord::Rollback if @reference.errors.present?

        # TODO maybe move to a callback, but maybe not.
        unless params[:possible_duplicate].present?
          if @reference.check_for_duplicate
            @possible_duplicate = true
            raise ActiveRecord::Rollback
          end
        end

        @reference.save!
        set_document_host
        make_default_reference @reference if params[:make_default]
        return true
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end

    def set_pagination
      params[:reference][:pagination] =
        case @reference
        when ArticleReference then params[:article_pagination]
        when BookReference    then params[:book_pagination]
        else                       nil
        end
    end

    def set_document_host
      @reference.document_host = request.host
    end

    def parse_author_names_string
      author_names_and_suffix = @reference.parse_author_names_and_suffix params[:reference].delete(:author_names_string)
      @reference.author_names.clear
      params[:reference][:author_names] = author_names_and_suffix[:author_names]
      params[:reference][:author_names_suffix] = author_names_and_suffix[:author_names_suffix]
    end

    def set_journal
      journal_name = params[:reference][:journal_name]

      # Set journal_name for the form.
      @reference.journal_name = journal_name

      # Set nil or valid publisher in the params.
      journal = Journal.find_or_create_by(name: journal_name)
      params[:reference][:journal] = journal.valid? ? journal : nil
    end

    def set_publisher
      publisher_string = params[:reference][:publisher_string]

      # Set publisher_string for the form.
      @reference.publisher_string = publisher_string

      # Add error or set valid publisher in the params.
      publisher = Publisher.create_with_place_form_string publisher_string
      if publisher.nil? && publisher_string.present?
        @reference.errors.add :publisher_string,
          "couldn't be parsed. In general, use the format 'Place: Publisher'."
      else
        params[:reference][:publisher] = publisher
      end
    end

    def clear_nesting_reference_id
      params[:reference][:nesting_reference_id] = nil
    end

    def clear_document_params_if_necessary
      return unless params[:reference][:document_attributes]
      return unless params[:reference][:document_attributes][:url].present?
      params[:reference][:document_attributes][:id] = nil
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

    def format_autosuggest_keywords reference, keyword_params
      replaced = []
      replaced << keyword_params[:keywords] || ''
      replaced << "author:'#{reference.author_names_string}'" if keyword_params[:author]
      replaced << "title:'#{reference.title}'" if keyword_params[:title]
      replaced << "year:#{keyword_params[:year]}" if keyword_params[:year]

      start_year = keyword_params[:start_year]
      end_year   = keyword_params[:end_year]
      if start_year && end_year
        replaced << "year:#{start_year}-#{end_year}"
      end
      replaced.join(" ").strip
    end

    def set_reference
      @reference = Reference.find params[:id]
    end
end
