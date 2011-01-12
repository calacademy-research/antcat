class ReferencesController < ApplicationController

  before_filter :authenticate_user!, :except => :index

  def index
    params[:q] = '' if ['review', 'new', 'clear'].include? params[:commit]
    params[:q].strip! if params[:q]
    @reviewing = params[:commit] == 'review'
    @seeing_whats_new = params[:commit] == 'new'
    @references = Reference.do_search params[:q], params[:page], @reviewing, @seeing_whats_new
  end

  def download
    redirect_to Document.find(params[:id]).actual_url
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
        set_authors
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference
        set_pagination
        @reference.update_attributes params[:reference]
        @reference.save!
        set_document_host
        raise ActiveRecord::RecordInvalid unless @reference.errors.empty?
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
      when ArticleReference: params[:article_pagination]
      when BookReference: params[:book_pagination]
      else nil
      end
  end

  def set_document_host
    @reference.document_host = request.host
  end

  def set_authors
    author_names_string = params[:reference][:author_names_string]
    authors_data = AuthorName.import_author_names_string author_names_string
    if authors_data[:author_names].empty? && author_names_string.present?
      @reference.errors.add :author_names_string, "couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
      @reference.author_names_string = author_names_string
      raise ActiveRecord::RecordInvalid.new @reference
    end
    @reference.author_names.clear
    params[:reference][:author_names] = authors_data[:author_names]
    params[:reference][:author_names_suffix] = authors_data[:author_names_suffix]
  end

  def set_journal
    params[:reference][:journal] = Journal.import params[:journal_name]
  end

  def set_publisher
    params[:reference][:publisher] = Publisher.import_string params[:publisher_string]
  end

  def render_json new = false
    ActiveSupport.escape_html_entities_in_json = true
    json = {
      :isNew => new,
      :content => render_to_string(:partial => 'reference',
                                   :locals => {:reference => @reference, :css_class => 'reference'}),
                                   :id => @reference.id,
                                   :success => @reference.errors.empty?
    }.to_json
    
    json = '<textarea>' + json + '</textarea>' unless Rails.env.cucumber? 
    render :json => json, :content_type => 'text/html'
  end

  def new_reference
    case params[:selected_tab]
    when 'Article': ArticleReference.new
    when 'Book':    BookReference.new
    when 'Nested':  NestedReference.new
    else            UnknownReference.new
    end
  end

  def get_reference
    selected_tab = params[:selected_tab]
    selected_tab = 'Unknown' if selected_tab == 'Other'
    Reference.find(params[:id]).becomes((selected_tab + 'Reference').constantize)
  end

end
