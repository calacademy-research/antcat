class ReferencesController < ApplicationController
  before_filter :authenticate_user!, :except => :index
  def index
    if params[:commit] == 'clear'
      params[:author] = params[:start_year] = params[:end_year] = params[:journal] = ''
    end
    @references = Reference.search(params).paginate(:page => params[:page])
  end

  def update
    @reference = Reference.find(params[:id])
    set_authors
    set_journal if @reference.respond_to? :journal
    set_publisher if @reference.respond_to? :publisher
    @reference.update_attributes(params[:reference])
    render_json
  end
  
  def create
    klass = case params[:selected_tab]
            when 'Article': ArticleReference
            when 'Book': BookReference
            else OtherReference
            end
    set_authors
    set_journal if klass == ArticleReference
    set_publisher if klass == BookReference
    @reference = klass.create(params[:reference])
    render_json true
  end
  
  def destroy
    @reference = Reference.find(params[:id])
    @reference.destroy
    head :ok
  end

  private
  def set_authors
    @reference.author_participations.delete_all if @reference
    authors_string = params[:reference].delete :authors_string
    params[:reference][:authors] = Author.import_authors_string authors_string
  end

  def set_journal
    params[:reference][:journal] = Journal.import :title => params[:journal_title]
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
      :success => @reference.valid?
    }
  end
end
