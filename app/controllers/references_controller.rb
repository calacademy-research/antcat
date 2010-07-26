class ReferencesController < ApplicationController
  def index
    if params[:commit] == 'clear'
      params[:author] = params[:start_year] = params[:end_year] = params[:journal] = ''
    end
    @references = Reference.search(params).paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @reference = Reference.find(params[:id])
  end
  
  def edit
    @reference = Reference.find(params[:id])
  end

  def update
    @reference = Reference.find(params[:id])
    if @reference.update_attributes(params[:reference])
      flash[:notice] = "Reference has been updated"
      redirect_to reference_url(@reference)
    else
      render :action => 'edit'
    end
  end
  
  def new
    @reference = Reference.new
  end
  
  def create
    @reference = Reference.new(params[:reference])
    if @reference.save
      flash[:notice] = "Successfully created reference."
      redirect_to references_url
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @reference = Reference.find(params[:id])
    @reference.destroy
    flash[:notice] = "Successfully destroyed reference."
    redirect_to references_url
  end
end
