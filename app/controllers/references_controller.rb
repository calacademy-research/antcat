class ReferencesController < ApplicationController

  before_filter :authenticate_user!, :except => :index

  def index
    if params[:commit] == 'clear'
      params[:author] = params[:start_year] = params[:end_year] = params[:journal] = ''
    end
    @references = Reference.search(params).paginate(:page => params[:page])
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
        @reference.attributes = params[:reference]
        @reference.save!
        raise ActiveRecord::RecordInvalid unless @reference.errors.empty?
      end
    rescue ActiveRecord::RecordInvalid
      @reference[:id] = nil if new
      @reference.instance_variable_set( :@new_record , new)
    end
    render_json new
  end

  def destroy
    @reference = Reference.find(params[:id])
    @reference.destroy
    head :ok
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

  def set_authors
    @reference.authors.clear
    params[:reference][:authors] = Author.import_authors_string params[:reference][:authors_string]
  end

  def set_journal
    params[:reference][:journal] = Journal.import params[:journal_title]
  end

  def set_publisher
    params[:reference][:publisher] = Publisher.import_string params[:publisher_string]
  end

  def render_json new = false
    render :json => {
      :isNew => new,
      :content => render_to_string(:partial => 'reference',
                                   :locals => {:reference => @reference, :css_class => 'reference'}),
                                   :id => @reference.id,
                                   :success => @reference.errors.empty?
    }
  end

  def new_reference
    case params[:selected_tab]
    when 'Article': ArticleReference.new
    when 'Book':    BookReference.new
    else            OtherReference.new
    end
  end

  def get_reference
    Reference.find(params[:id]).becomes((params[:selected_tab] + 'Reference').constantize)
  end
end
