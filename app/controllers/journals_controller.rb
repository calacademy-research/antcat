class JournalsController < ApplicationController

  before_filter :authenticate_user!

  def index
    respond_to do |format|
      format.html {@journals = Journal.all(:order => :name)}
      format.json {render :json => Journal.search(params[:term]).to_json}
    end
  end
  
  def new
    @journal = Journal.new
  end
  
  def create
    @journal = Journal.new(params[:journal])
    if @journal.save
      flash[:notice] = "Successfully created journal."
      render :action => 'edit'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @journal = Journal.find(params[:id])
  end
  
  def update
    @journal = Journal.find(params[:id])
    if @journal.update_attributes(params[:journal])
      flash[:notice] = "Successfully updated journal."
    end
    render :action => 'edit'
  end

end
