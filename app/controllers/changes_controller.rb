class ChangesController < ApplicationController

  def index
    @changes = Change.creations.paginate page: params[:page]
  end

  def show
    @change = Change.find params[:id]
  end

end
