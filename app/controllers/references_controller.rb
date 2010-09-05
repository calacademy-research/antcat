class ReferencesController < ApplicationController
  before_filter :authenticate_user!, :except => :index
  def index
    if params[:commit] == 'clear'
      params[:author] = params[:start_year] = params[:end_year] = params[:journal] = ''
    end
    @references = WardReference.search(params).paginate(:page => params[:page])
  end

  def update
    @reference = WardReference.find(params[:id])
    @reference.update_attributes(params[:ward_reference])
    render_json
  end
  
  def create
    @reference = WardReference.new(params[:ward_reference])
    @reference.save
    render_json true
  end
  
  def destroy
    @reference = WardReference.find(params[:id])
    @reference.destroy
    head :ok
  end

  private
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
