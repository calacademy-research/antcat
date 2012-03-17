# coding: UTF-8
class ReferencesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :download]
  skip_before_filter :authenticate_user!, :if => :preview?

  def index
    searching = params[:q].present?
    params[:search_selector] ||= 'Search for'
    if ['review', 'new', 'clear'].include? params[:commit]
      params[:q] = ''
    end
    params[:q].strip! if params[:q]
    params[:review] = params[:commit] == 'review'
    params[:whats_new] = params[:commit] == 'new'

    @endnote_export_confirmation_message = <<EOS
AntCat will download these references to a file named "antcat_references.utf8.endnote_import". When your browser asks, save this file. Then use EndNote's Import function on its File menu to import the file. Choose "EndNote Import" from Import Options, and "Unicode (UTF-8)" as the Text Translation.
EOS
    unless searching
      @endnote_export_confirmation_message << "\nSince there are no search criteria, AntCat will download all ten thousand references. This will take several minutes."
    end

    params[:is_author_search] = params[:search_selector] == 'Search for author(s)'

    respond_to do |format|
      format.html   {
        @references = Reference.do_search params
      }
      format.endnote_import  {
        references = Reference.do_search params.merge :format => :endnote_import
        render text: Exporters::Endnote::Formatter.format(references)
      }
    end
  end

  def download
    document = ReferenceDocument.find params[:id]
    if document.downloadable_by? current_user
      redirect_to document.actual_url
    else
      head 401
    end
  end

  def create
    @reference = new_reference
    save true
  end

  def update
    @reference = get_reference
    save false
  end

  def save new
    begin
      Reference.transaction do
        clear_document_params_if_necessary
        clear_nested_reference_id unless @reference.kind_of? NestedReference
        parse_author_names_string
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference
        set_pagination
        # kludge around Rails 3 behavior that uses the type to look up a record - so you can't update the type!
        Reference.connection.execute "UPDATE `references` SET type = '#{@reference.type}' WHERE id = '#{@reference.id}'" unless new
        @reference.update_attributes params[:reference]

        @possible_duplicate = @reference.check_for_duplicate unless params[:possible_duplicate].present?
        unless @possible_duplicate
          @reference.save!
          set_document_host
        end

        raise ActiveRecord::RecordInvalid.new @reference unless @reference.errors.empty?
      end
    rescue ActiveRecord::RecordInvalid
      @reference[:id] = nil if new
      @reference.instance_variable_set :@new_record, new
    end
    render_json new
  end

  def destroy
    @reference = Reference.find(params[:id])
    if @reference.destroy
      json = {:success => true}
    else
      json = {:success => false, :message => @reference.errors[:base]}.to_json
    end
    render :json => json
  end

  private
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
    params[:reference][:journal] = Journal.import params[:journal_name]
  end

  def set_publisher
    publisher_string = params[:publisher_string]
    publisher = Publisher.import_string publisher_string
    if publisher.nil? and publisher_string.present?
      @reference.errors.add :publisher_string, "Publisher string couldn't be parsed. In general, use the format 'Place: Publisher'. Otherwise, please post a message on http://groups.google.com/group/antcat/, and we'll see what we can do!"
      @publisher_string = publisher_string
      raise ActiveRecord::RecordInvalid.new @reference
    end
    params[:reference][:publisher] = publisher
  end

  def clear_nested_reference_id
    params[:reference][:nested_reference_id] = nil
  end

  def clear_document_params_if_necessary
    params[:reference][:document_attributes][:id] = nil unless params[:reference][:document_attributes][:url].present?
  end

  def render_json new = false
    json = {
      :isNew => new,
      :content => render_to_string(:partial => 'reference',
                                   :locals => {:reference => @reference, :publisher_string => @publisher_string, :css_class => 'reference'}),
                                   :id => @reference.id,
                                   :success => @reference.errors.empty?
    }.to_json

    json = '<textarea>' + json + '</textarea>' unless Rails.env.test?
    render :json => json, :content_type => 'text/html'
  end

  def new_reference
    case params[:selected_tab]
    when 'Article' then ArticleReference.new
    when 'Book' then    BookReference.new
    when 'Nested' then  NestedReference.new
    else                UnknownReference.new
    end
  end

  def get_reference
    selected_tab = params[:selected_tab]
    selected_tab = 'Unknown' if selected_tab == 'Other'
    type = selected_tab + 'Reference'
    reference = Reference.find(params[:id]).becomes((type).constantize)
    reference.type = type
    reference
  end

end
