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
    @reference.update_attributes(params[:reference])
    render_json
  end
  
  def create
    set_authors
    @reference = Reference.create(params[:reference])
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
    params[:reference][:authors] = Author.parse_authors_string authors_string
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
