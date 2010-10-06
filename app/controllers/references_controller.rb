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
    authors_valid = true
    begin
      Reference.transaction do
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference
        set_pagination
        authors_valid = set_authors
        @reference.attributes = params[:reference]
        @reference.save!
        unless @reference.errors.empty?
          @reference.instance_variable_set( :@new_record , new)
          @reference[:id] = nil if new
          raise ActiveRecord::Rollback
        end
      end
    rescue ActiveRecord::RecordInvalid
      @reference[:id] = nil if new
      @reference.instance_variable_set( :@new_record , new)
    end
    @reference.errors.add_to_base "Authors can't be blank" unless authors_valid
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
    authors_string = params[:reference][:authors_string]
    if authors_string.blank?
      false
    else
      params[:reference][:authors] = Author.import_authors_string authors_string
      true
    end
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
    reference = Reference.find(params[:id])
    return reference if reference.type == params[:selected_tab]
    reference.update_attribute(:type, params[:selected_tab] + 'Reference')
    Reference.find(params[:id])
  end
end
