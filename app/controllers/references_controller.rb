class ReferencesController < ApplicationController
  before_filter :authenticate_editor, except: [
    :index, :download, :autocomplete, :show, :search, :endnote_export, :latest_additions]
  before_filter :authenticate_superadmin, only: [:approve_all]
  before_filter :set_reference, only: [
    :show, :edit, :update, :destroy, :start_reviewing, :finish_reviewing, :restart_reviewing]
  before_filter :redirect_if_search_matches_id, only: [:index, :search]
  # TODO remove filter from the index? Currently only for legacy reasons,
  #   would break non-restful `reference_path`s such as /index/q=21255

  def index
    @references = Reference.list_references params
  end

  def show
  end

  def new
    @reference = Reference.new
  end

  def edit
  end

  def create
    @reference = new_reference
    if save
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
      redirect_to reference_path(@reference), notice: <<-MSG
        Reference was successfully updated.
        <strong>#{view_context.link_to 'Back to the index', references_path}</strong>.
      MSG
    else
      render :edit
    end
  end

  def destroy
    if @reference.any_references?
      # TODO list which refereces
      redirect_to reference_path(@reference),
        notice: "This reference can't be deleted, as there are other references to it."
      return
    end

    @reference.destroy
    redirect_to references_path, notice: 'Reference was successfully destroyed.'
  end

  def download
    document = ReferenceDocument.find params[:id]
    if document.downloadable?
      redirect_to document.actual_url
    else
      head :unauthorized
    end
  end

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

  def approve_all
    Reference.approve_all
    redirect_to latest_changes_references_path, notice: "Approved all references."
  end

  def search
    return redirect_to action: :index unless params[:q].present?
    @references = Reference.do_search params
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

    references =  if id
                    Reference.where(id: id) # where and not find because we need to return an array
                  elsif searching
                    Reference.do_search params.merge endnote_export: true
                  else
                    Reference.list_all_references_for_endnote
                  end

    render plain: Exporters::Endnote::Formatter.format(references)

    rescue
      render plain: <<-MSG.squish
        Looks like something went wrong.
        Exporting missing references is not supported.
        If you tried to export a list of references, try to filter the query with "type:nomissing".
      MSG
  end

  def autocomplete
    search_query = params[:q] || ''

    search_options = {}
    keyword_params = Reference.send(:extract_keyword_params, search_query)

    search_options[:reference_type] = :nomissing
    search_options[:items_per_page] = 5
    search_options.merge! keyword_params
    search_results = Reference.send(:fulltext_search, search_options)

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

    def make_default_reference reference
      DefaultReference.set session, reference
    end

    def save
      Reference.transaction do
        clear_document_params_if_necessary
        set_pagination
        clear_nesting_reference_id unless @reference.kind_of? NestedReference
        parse_author_names_string
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference

        @reference.attributes = params[:reference]

        return if @reference.errors.present?

        @possible_duplicate = @reference.check_for_duplicate unless params[:possible_duplicate].present?
        return if @possible_duplicate

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
        when BookReference then params[:book_pagination]
        else nil
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
      journal = if journal_name.present?
        Journal.find_or_create_by!(name: journal_name)
      end
      @reference.journal = journal
    end

    def set_publisher
      publisher_string = params[:reference][:publisher_string]
      publisher = if publisher_string.present?
        Publisher.create_with_place_form_string publisher_string
      end
      @reference.publisher = publisher

      if publisher.nil? && publisher_string.present?
        @reference.publisher_string = publisher_string
        @reference.errors.add :publisher_string, <<-MSG.squish
          couldn't be parsed. In general, use the format 'Place: Publisher'.
        MSG
      end
    end

    def clear_nesting_reference_id
      params[:reference][:nesting_reference_id] = nil
    end

    def clear_document_params_if_necessary
      return unless params[:reference][:document_attributes]
      params[:reference][:document_attributes][:id] = nil unless params[:reference][:document_attributes][:url].present?
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
      reference = @reference.becomes(type)
      reference.type = type
      reference
    end

    def format_autosuggest_keywords reference, keyword_params
      replaced = []
      replaced << keyword_params[:keywords] || ''
      replaced << "author:'#{reference.author_names_string}'" if keyword_params[:author]
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

    def reference_params
      raise NotImplementedError
      # TODO
      #params.require(:reference).permit(:....)
    end
end
